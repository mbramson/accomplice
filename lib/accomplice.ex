defmodule Accomplice do
  @moduledoc """
  Documentation for Accomplice.
  """

  import Accomplice.Helpers

  @doc """
  `Accomplice.group/2` accepts a list of unordered elements and produces a list of
  groups of those elements subjected to the passed in constraints.
  """
  @spec group(list(any()), map()) :: list(any())
  def group([], _constraints), do: []
  def group(elements, %{minimum: _, ideal: _, maximum: _} = constraints) do
    group([], elements, constraints)
  end
  def group(elements, constraints) do
    group_simple([], elements, constraints)
  end

  @spec group_simple(list(any()), list(any()), map()) :: list(any())
  def group_simple([current_group | _] = grouped, [], %{minimum: minimum}) do
    if length(current_group) < minimum do
      {:error, :group_size_below_minimum}
    else
      grouped
    end
  end
  def group_simple([], ungrouped, constraints) do
    group_simple([[]], ungrouped, constraints)
  end
  def group_simple([current_group | complete_groups], ungrouped, constraints = %{minimum: minimum, maximum: maximum}) do

    cond do
      length(current_group) < minimum ->
        # pluck a random element from the ungrouped list and add it to the current_group.
        # recursively call group with the new grouped and rest of the ungrouped items
        {new_element, rest_of_ungrouped} = pop_random_element_from_list(ungrouped)
        new_current_group = [new_element | current_group]
        new_grouped = [new_current_group | complete_groups]
        group_simple(new_grouped, rest_of_ungrouped, constraints)

      length(current_group) >= maximum ->
        # add another empty list to the grouped list so that subsequent calls start
        # adding to it
        new_grouped = [[], current_group | complete_groups]
        group_simple(new_grouped, ungrouped, constraints)

      true ->
        # this group has at least the minimum amount of elements. Pluck a
        # random element from the ungrouped list and add it to the
        # current_group. recurseively call group with the new grouped and rest
        # of the ungrouped items
        {new_element, rest_of_ungrouped} = pop_random_element_from_list(ungrouped)
        new_current_group = [new_element | current_group]
        new_grouped = [new_current_group | complete_groups]
        case group_simple(new_grouped, rest_of_ungrouped, constraints) do
          {:error, _} ->
            # If a constraint is violated by further grouping, then try again with a new
            # group, leaving this group less than the maximum.
            new_grouped = [[], current_group | complete_groups]
            group_simple(new_grouped, ungrouped, constraints)
          grouped ->
            grouped
        end
    end
  end

  @spec group(list(any()), list(any()), map()) :: list(any())
  def group([current_group | _] = grouped, [], %{minimum: minimum}) do
    if length(current_group) < minimum do
      :impossible
    else
      grouped
    end
  end
  def group([], ungrouped, constraints), do: group([[]], ungrouped, constraints)
  def group([current_group | _] = grouped, ungrouped, constraints) do
    # Get a list of actions we can try from here, ordered such that the actions most
    # likely to meet the constraints come first
    actions = create_actions(current_group, ungrouped, constraints)
    # Attempt to take the actions in order
    attempt_actions(actions, grouped, ungrouped, constraints)
  end

  @spec attempt_actions(Helpers.actions, list(list(any())), list(any()), map()) :: list(list(any())) | :impossible
  def attempt_actions([], _, _, _), do: :impossible
  def attempt_actions(:impossible, _, _, _), do: :impossible
  def attempt_actions([:complete | remaining_actions], grouped, ungrouped, constraints) do
    # The action is to complete the group. So we just append an empty list to the groups
    # which will be the new current group
    new_grouped = [[] | grouped]

    # Try to group with the new constraints. If we receive the :impossible atom, then there
    # are no possible configurations of the remaining elements given the action we just took.
    # Try a new action. Otherwise, we have a legal configuration, so return it.
    case group(new_grouped, ungrouped, constraints) do
      :impossible -> attempt_actions(remaining_actions, grouped, ungrouped, constraints)
      grouped -> grouped
    end
  end
  def attempt_actions([:add | remaining_actions], grouped, ungrouped, constraints) do
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
    case group(new_grouped, new_ungrouped, constraints) do
      :impossible -> attempt_actions(remaining_actions, grouped, ungrouped, constraints)
      grouped -> grouped
    end
  end
end
