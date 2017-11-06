defmodule Accomplice do
  @moduledoc """
  Documentation for Accomplice.
  """

  @doc """
  `Accomplice.group/2` accepts a list of unordered elements and produces a list of
  groups of those elements subjected to the passed in constraints.
  """
  @spec group(list(any()), map()) :: list(any())
  def group([], _constraints), do: []
  def group(elements, constraints) do
    group([], elements, constraints)
  end

  @spec group(list(any()), list(any()), map()) :: list(any())
  def group([current_group | _] = grouped, [], %{minimum: minimum}) do
    if length(current_group) < minimum do
      {:error, :group_size_below_minimum}
    else
      grouped
    end
  end
  def group([], ungrouped, constraints) do
    group([[]], ungrouped, constraints)
  end
  def group([current_group | complete_groups], ungrouped, constraints = %{minimum: minimum, maximum: maximum}) do

    cond do
      length(current_group) < minimum ->
        # pluck a random element from the ungrouped list and add it to the current_group.
        # recursively call group with the new grouped and rest of the ungrouped items
        {new_element, rest_of_ungrouped} = pop_random_element_from_list(ungrouped)
        new_current_group = [new_element | current_group]
        new_grouped = [new_current_group | complete_groups]
        group(new_grouped, rest_of_ungrouped, constraints)

      length(current_group) >= maximum ->
        # add another empty list to the grouped list so that subsequent calls start
        # adding to it
        new_grouped = [[], current_group | complete_groups]
        group(new_grouped, ungrouped, constraints)

      true ->
        # this group has at least the minimum amount of elements. Pluck a
        # random element from the ungrouped list and add it to the
        # current_group. recurseively call group with the new grouped and rest
        # of the ungrouped items
        #
        # this case will be handled differently once the ideal constraint is
        # implemented
        {new_element, rest_of_ungrouped} = pop_random_element_from_list(ungrouped)
        new_current_group = [new_element | current_group]
        new_grouped = [new_current_group | complete_groups]
        group(new_grouped, rest_of_ungrouped, constraints)
    end
  end

  @spec pop_random_element_from_list(list(any())) :: {any(), list(any())}
  def pop_random_element_from_list(list) do
    element_index = Enum.random(1..length(list)) - 1
    List.pop_at(list, element_index)
  end
end
