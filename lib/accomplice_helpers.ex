defmodule Accomplice.Helpers do
  @moduledoc false

  @doc false
  @spec validate_options(map()) :: map() | {:error, atom()}
  def validate_options(%{minimum: min, ideal: ideal, maximum: max} = options) do
    cond do
      min < 1 || max < 1 || ideal < 1 -> {:error, :size_constraint_below_one}
      min > max                       -> {:error, :minimum_above_maximum}
      ideal < min || ideal > max      -> {:error, :ideal_not_between_min_and_max}
      true                            -> options
    end
  end
  def validate_options(%{minimum: min, maximum: max} = options) do
    cond do
      min < 1 || max < 1 -> {:error, :size_constraint_below_one}
      min > max          -> {:error, :minimum_above_maximum}
      true               -> options
    end
  end
  def validate_options(options) when is_map(options), do: {:error, :missing_size_constraint}
  def validate_options(_), do: {:error, :options_is_not_map}

  @doc false
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
