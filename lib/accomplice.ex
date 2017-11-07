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
      {:error, :group_size_below_minimum}
    else
      grouped
    end
  end
end
