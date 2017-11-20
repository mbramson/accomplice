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
  def create_actions(current_group, [], %{minimum: minimum, ideal: ideal, maximum: maximum}) do
    current_group_length = length(current_group)
    if current_group_length < minimum do
      :impossible
    else
      [:complete]
    end
  end
  def create_actions(current_group, ungrouped, %{minimum: minimum, ideal: ideal, maximum: maximum}) do
    current_group_length = length(current_group)
    cond do
      current_group_length < minimum ->
        # when the current_group's length is less than the minimum constraint,
        # our only option is to add en element.
        [:add]
      current_group_length == maximum ->
        # when the current_group's length is equal to the maximum constraint,
        # our only option is to complete the group.
        [:complete]
      current_group_length < ideal ->
        # when the current group's length is less than the ideal, we first want
        # to try adding an element if there are any to add, then we'll try
        # completing the group since we know that we're at least at the minimum
        # length.
        [:add, :complete]
      current_group_length == ideal ->
        # when the current group's length is at ideal, we first want to try
        # completing the group, then try adding an element, since we know that
        # we're below the maximum current_group length.
        [:complete, :add]
    end
  end

  @doc false
  @spec generate_memo_key(list(any()), list(any())) :: String.t
  def generate_memo_key(current_group, ungrouped) do
    current_group_string = convert_list_to_string(current_group)
    ungrouped_string     = convert_list_to_string(ungrouped)
    "[#{current_group_string}][#{ungrouped_string}]"
  end

  @spec convert_list_to_string(list(any())) :: String.t
  defp convert_list_to_string(list) when is_list(list) do
    list
    |> Enum.sort
    |> Enum.map(&(inspect &1))
    |> Enum.join(",")
  end
end
