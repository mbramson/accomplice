defmodule Accomplice.Helpers do

  @doc false
  @spec pop_random_element_from_list(list(any())) :: {any(), list(any())}
  def pop_random_element_from_list(list) do
    element_index = Enum.random(1..length(list)) - 1
    List.pop_at(list, element_index)
  end
end
