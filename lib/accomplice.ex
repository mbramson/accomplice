defmodule Accomplice do
  @moduledoc """
  Documentation for Accomplice.
  """

  alias Accomplice.Constraint

  @doc """
  `Accomplice.group/2` accepts a list of unordered elements and produces a list of
  groups of those elements subjected to the passed in constraints.
  """
  @spec group(list(any()), list(Constraint.t)) :: list(any())
  def group([], constraints), do: []
  def group(elements, constraints) do
    group([], elements, constraints)
  end

  @spec group(list(any()), list(any()), list(Constraint.t)) :: list(any())
  def group(grouped, [], _constraints), do: grouped
  def group([], ungrouped, constraints) do
    group([[]], ungrouped, constraints)
  end
  def group([current_group | complete_groups] = grouped, ungrouped, constraints) do
    %Constraint{minimum: minimum, maximum: maximum} = group_size_constraint(constraints)

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
        new_grouped = [[], current_group | completed_groups]
        group(new_grouped, ungrouped, constraints)

      true ->
        # this group has at least the minimum amount of elements. append a new empty current
        # group and call recursively
        new_grouped = [[], current_group | completed_groups]
        group(new_grouped, ungrouped, constraints)

    end
  end

  @spec pop_random_element_from_list(list(any())) :: {any(), list(any())}
  def pop_random_element_from_list(list) do
    element_index = Enum.random(1..length(list)) - 1
    {element, rest_of_list} = List.pop_at(list, element_index)
  end

  def group_size_constraint(constraints) do
    maybe_group_size = constraints |> Enum.find(fn c -> c[:type] == :group_size end)
    case maybe_group_size do
      nil ->
        Accomplice.Constraint.GroupSize.default_args
      group_size_constraint ->
        group_size_constraint
    end
  end
end
