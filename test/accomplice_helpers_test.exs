defmodule AccompliceHelpersTest do
  use ExUnit.Case

  alias Accomplice.Helpers

  describe "pop_random_element_from_list/1" do
    test "returns an element and the rest of the list" do
      assert {element, rest_of_list} = Helpers.pop_random_element_from_list([1, 2, 3])
      assert element in [1, 2, 3]
      assert element not in rest_of_list
    end
  end
end
