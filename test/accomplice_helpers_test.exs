defmodule AccompliceHelpersTest do
  use ExUnit.Case
  use Quixir

  alias Accomplice.Helpers

  describe "pop_random_element_from_list/1" do
    test "returns an element and the rest of the list" do
      ptest original_list: list() do
        assert {element, rest_of_list} = Helpers.pop_random_element_from_list(original_list)
        # don't test this if original list is an empty list. nil won't be in it.
        unless is_nil(element) do
          assert element in original_list
        end
        # don't test this if original list contains non-unique elements. element might be in it.
        if original_list |> Enum.uniq |> length == length(original_list) do
          assert element not in rest_of_list
        end
      end
    end
  end
end
