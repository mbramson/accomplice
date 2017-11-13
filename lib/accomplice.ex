defmodule Accomplice do
  @moduledoc """
  Accomplice contains a number of functions for grouping lists of elements.

  It accepts a list of elements and a map of options and returns a list of
  lists of the original elements, where each sub-list represents a grouping of
  those elements.

  As an example:

      iex> Accomplice.group(['a', 'b', 'c', 'd', 'e', 'f', 'g'], %{minimum: 2, maximum: 3})
      [['g', 'f'], ['e', 'd'], ['c', 'b', 'a']]

  If the the given options cannot be satisified, the `:impossible` atom is returned.

      iex> Accomplice.group(['a', 'b', 'c', 'd', 'e'], %{minimum: 2, maximum: 2})
      :impossible

  The options that can be supplied to grouping functions are the following:

  - `:minimum` (required) - The minimum acceptable size of a group. This
  constraint will always be satisfied if a grouping is returned.

  - `:maximum` (required) - The maximum acceptable size of a group. This
  constraint will always be satisfied if a grouping is returned.

  - `:ideal` (optional) - The ideal group number that the grouping algorithm
  will try to satisfy. Note that because the algorithm returns the first
  grouping that satisfies the hard constraints, the returned grouping is not
  guaranteed to adhere to the ideal option even if there might exist some
  configuration of groupings that would contain more groupings that are the
  ideal size. The grouping functions do not perform an exhaustive search.
  """

  import Accomplice.Helpers

  @doc """
  Accepts a list of unordered elements and produces a list of groups of those
  elements subjected to the passed in options. Returns :impossible if the
  passed in options cannot be satisfied.

  ## Examples:
      iex> constraints = %{minimum: 2, ideal: 3, maximum: 4}
      iex> group(['a', 'b', 'c', 'd', 'e', 'f'], constraints)
      [['f', 'e', 'd'], ['c', 'b', 'f']]
  """
  @spec group(list(any()), map()) :: list(any()) | :impossible
  def group([], _options), do: []
  def group(elements, %{minimum: _, ideal: _, maximum: _} = options) do
    group([], elements, options)
  end
  def group(elements, options) do
    group_simple([], elements, options)
  end

  @doc """
  Same as `group/2`, but it shuffles the elements first so that the elements in
  the returned grouping are in random order.
  """
  @spec shuffled_group(list(any()), map()) :: list(any()) | :impossible
  def shuffled_group(elements, options) do
    elements |> Enum.shuffle |> group(options)
  end

  @spec group_simple(list(any()), list(any()), map()) :: list(any()) | :impossible
  defp group_simple([current_group | _] = grouped, [], %{minimum: minimum}) do
    if length(current_group) < minimum do
      :impossible
    else
      grouped
    end
  end
  defp group_simple([], ungrouped, options) do
    group_simple([[]], ungrouped, options)
  end
  defp group_simple([current_group | complete_groups], ungrouped, options = %{minimum: minimum, maximum: maximum}) do

    cond do
      length(current_group) < minimum ->
        # pluck a random element from the ungrouped list and add it to the current_group.
        # recursively call group with the new grouped and rest of the ungrouped items
        {new_element, rest_of_ungrouped} = pop(ungrouped)
        new_current_group = [new_element | current_group]
        new_grouped = [new_current_group | complete_groups]
        group_simple(new_grouped, rest_of_ungrouped, options)

      length(current_group) >= maximum ->
        # add another empty list to the grouped list so that subsequent calls start
        # adding to it
        new_grouped = [[], current_group | complete_groups]
        group_simple(new_grouped, ungrouped, options)

      true ->
        # this group has at least the minimum amount of elements. Pluck a
        # random element from the ungrouped list and add it to the
        # current_group. recurseively call group with the new grouped and rest
        # of the ungrouped items
        {new_element, rest_of_ungrouped} = pop(ungrouped)
        new_current_group = [new_element | current_group]
        new_grouped = [new_current_group | complete_groups]
        case group_simple(new_grouped, rest_of_ungrouped, options) do
          :impossible ->
            # If a constraint is violated by further grouping, then try again with a new
            # group, leaving this group less than the maximum.
            new_grouped = [[], current_group | complete_groups]
            group_simple(new_grouped, ungrouped, options)
          grouped ->
            grouped
        end
    end
  end

  @spec group(list(any()), list(any()), map()) :: list(any()) | :impossible
  defp group([current_group | _] = grouped, [], %{minimum: minimum}) do
    if length(current_group) < minimum do
      :impossible
    else
      grouped
    end
  end
  defp group([], ungrouped, options), do: group([[]], ungrouped, options)
  defp group([current_group | _] = grouped, ungrouped, options) do
    # Get a list of actions we can try from here, ordered such that the actions most
    # likely to meet the constraints come first
    actions = create_actions(current_group, ungrouped, options)
    # Attempt to take the actions in order
    attempt_actions(actions, grouped, ungrouped, options)
  end

  @spec attempt_actions(Helpers.actions, list(list(any())), list(any()), map()) :: list(list(any())) | :impossible
  defp attempt_actions([], _, _, _), do: :impossible
  defp attempt_actions(:impossible, _, _, _), do: :impossible
  defp attempt_actions([:complete | remaining_actions], grouped, ungrouped, options) do
    # The action is to complete the group. So we just append an empty list to the groups
    # which will be the new current group
    new_grouped = [[] | grouped]

    # Try to group with the new constraints. If we receive the :impossible atom, then there
    # are no possible configurations of the remaining elements given the action we just took.
    # Try a new action. Otherwise, we have a legal configuration, so return it.
    case group(new_grouped, ungrouped, options) do
      :impossible -> attempt_actions(remaining_actions, grouped, ungrouped, options)
      grouped -> grouped
    end
  end
  defp attempt_actions([:add | remaining_actions], grouped, ungrouped, options) do
    # The action is to add an ungrouped element to the current group. Pop an element off
    # of the ungrouped list and append it to the front of the current_group. Reassemble
    # the grouped items with the new element,
    [current_group | completed_groups] = grouped
    [element_to_add | new_ungrouped] = ungrouped
    new_current_group = [element_to_add | current_group]
    new_grouped = [new_current_group | completed_groups]

    # Try to group with the new constraints. If we receive the :impossible atom, then there
    # are no possible configurations of the remaining elements given the action we just took.
    # Try a new action. Otherwise, we have a legal configuration, so return it.
    case group(new_grouped, new_ungrouped, options) do
      :impossible -> attempt_actions(remaining_actions, grouped, ungrouped, options)
      grouped -> grouped
    end
  end
end
