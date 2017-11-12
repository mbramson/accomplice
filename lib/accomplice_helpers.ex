defmodule Accomplice.Helpers do
  @moduledoc false

  @doc false
  @spec pop_random_element_from_list(list(any())) :: {any(), list(any())}
  def pop_random_element_from_list(list) do
    element_index = Enum.random(1..length(list)) - 1
    List.pop_at(list, element_index)
  end

  @spec pop(list(any())) :: {any(), list(any())} | {nil, list(any())}
  def pop([]), do: {nil, []}
  def pop([head | tail]), do: {head, tail}

  @type actions :: nonempty_list(:add | :complete) | :impossible

  @doc false
  @spec create_actions(list(list(any())), list(any()), map()) :: actions
  def create_actions(current_group, ungrouped, %{minimum: minimum, ideal: ideal, maximum: maximum}) do
    current_group_length = length(current_group)
    cond do
      current_group_length < minimum ->
        # when the current_group's length is less than the minimum constraint,
        # our only option is to add en element. If there are no elements to add,
        # then we have no legal action and so return the :impossible atom
        case ungrouped do
          []        -> :impossible
          ungrouped -> add_actions(ungrouped)
        end
      current_group_length == maximum ->
        # when the current_group's length is equal to the maximum constraint,
        # our only option is to complete the group.
        [:complete]
      current_group_length < ideal ->
        # when the current group's length is less than the ideal, we first want
        # to try adding an element, then we'll try completing the group since we
        # know that we're at least at the minimum length.
        add_actions(ungrouped) ++ [:complete]
      current_group_length == ideal ->
        # when the current group's length is at ideal, we first want to try completing
        # the group, then try adding the elements, since we know that we're below the
        # maximum current_group length.
        [:complete | add_actions(ungrouped)]
    end
  end

  @spec add_actions(list(any())) :: list({:add, any()})
  defp add_actions([]), do: []
  defp add_actions(ungrouped) do
    for _ <- 1..length(ungrouped), do: :add
  end

end
