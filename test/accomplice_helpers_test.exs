defmodule AccompliceHelpersTest do 
  use ExUnit.Case
  use Quixir

  alias Accomplice.Helpers
  import OrderInvariantCompare # for <~> operator

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

  describe "create_actions/3" do
    test "when there are no ungrouped elements left and we're above minimum, complete the group" do
      assert [:complete] == Helpers.create_actions([1], [], %{minimum: 1, ideal: 1, maximum: 1})
      assert [:complete] == Helpers.create_actions([1], [], %{minimum: 1, ideal: 3, maximum: 3})
      assert [:complete] == Helpers.create_actions([1, 2], [], %{minimum: 2, ideal: 2, maximum: 2})
      assert [:complete] == Helpers.create_actions([1, 2], [], %{minimum: 2, ideal: 3, maximum: 3})
    end

    test "when there are no ungrouped elements left and we're below minimum, return :impossible" do
      assert :impossible == Helpers.create_actions([], [], %{minimum: 2, ideal: 2, maximum: 2})
      assert :impossible == Helpers.create_actions([1], [], %{minimum: 3, ideal: 3, maximum: 3})
    end

    test "when the current_group is below minimum constraint, recommend adding an element to current group" do
      assert [{:add, 1}] == Helpers.create_actions([], [1], %{minimum: 1, ideal: 1, maximum: 1})
      assert [{:add, 1}] == Helpers.create_actions([], [1], %{minimum: 2, ideal: 2, maximum: 2})
      assert [{:add, 2}] == Helpers.create_actions([1], [2], %{minimum: 2, ideal: 2, maximum: 2})
      assert [{:add, 1}, {:add, 2}] <~> Helpers.create_actions([], [1, 2], %{minimum: 1, ideal: 1, maximum: 1})
    end

    test "when the current_group is at the maximum constraint, only action is to complete the group" do
      assert [:complete] == Helpers.create_actions([1], [], %{minimum: 1, ideal: 1, maximum: 1})
      assert [:complete] == Helpers.create_actions([1], [2], %{minimum: 1, ideal: 1, maximum: 1})
      assert [:complete] == Helpers.create_actions([1, 2], [2], %{minimum: 1, ideal: 1, maximum: 2})
    end

    test "when the current_group is below ideal constraint, but equal or above minimum, add elements, then complete group" do
      assert [{:add, 2}, :complete] == Helpers.create_actions([1], [2], %{minimum: 1, ideal: 2, maximum: 2})
      assert [{:add, 3}, :complete] == Helpers.create_actions([1, 2], [3], %{minimum: 1, ideal: 3, maximum: 3})
    end

    test "when the current_group is at ideal constraint, but below the maximum constraint, complete, then add elements" do
      assert [:complete, {:add, 2}] == Helpers.create_actions([1], [2], %{minimum: 1, ideal: 1, maximum: 2})
      assert [:complete, {:add, 3}] == Helpers.create_actions([1, 2], [3], %{minimum: 1, ideal: 2, maximum: 3})
      assert [:complete, {:add, 3}] == Helpers.create_actions([1, 2], [3], %{minimum: 2, ideal: 2, maximum: 3})
      assert [:complete, {:add, 4}] == Helpers.create_actions([1, 2, 3], [4], %{minimum: 1, ideal: 3, maximum: 4})
      assert [:complete, {:add, 4}] == Helpers.create_actions([1, 2, 3], [4], %{minimum: 2, ideal: 3, maximum: 4})
      assert [:complete, {:add, 4}] == Helpers.create_actions([1, 2, 3], [4], %{minimum: 3, ideal: 3, maximum: 4})

      assert [:complete | add_actions] = Helpers.create_actions([1], [2, 3, 4], %{minimum: 1, ideal: 1, maximum: 2})
      assert add_actions <~> [{:add, 2}, {:add, 3}, {:add, 4}]
    end

    test "there are no invalid inputs" do
      ptest [min: positive_int(), ideal: positive_int(), max: positive_int(), ungrouped: list(of: any(), min: 0, max: 10), current_group: list(of: any(), min: 0, max: 10)], repeat_for: 30 do
        Helpers.create_actions(current_group, ungrouped, %{minimum: min, ideal: ideal, maximum: max})
      end
    end
  end
end
