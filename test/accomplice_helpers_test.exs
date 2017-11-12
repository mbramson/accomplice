defmodule AccompliceHelpersTest do 
  use ExUnit.Case
  use Quixir

  alias Accomplice.Helpers
  import OrderInvariantCompare # for <~> operator

  describe "pop/1" do
    test "returns the head and tail if the list contains elements" do
      assert Helpers.pop([1,2,3,4]) == {1, [2,3,4]}
    end
    test "returns nil and an empty list if given an empty list" do
      assert Helpers.pop([]) == {nil, []}
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
      assert [:add] == Helpers.create_actions([], [1], %{minimum: 1, ideal: 1, maximum: 1})
      assert [:add] == Helpers.create_actions([], [1], %{minimum: 2, ideal: 2, maximum: 2})
      assert [:add] == Helpers.create_actions([1], [2], %{minimum: 2, ideal: 2, maximum: 2})
      assert [:add, :add] <~> Helpers.create_actions([], [1, 2], %{minimum: 1, ideal: 1, maximum: 1})
    end

    test "when the current_group is at the maximum constraint, only action is to complete the group" do
      assert [:complete] == Helpers.create_actions([1], [], %{minimum: 1, ideal: 1, maximum: 1})
      assert [:complete] == Helpers.create_actions([1], [2], %{minimum: 1, ideal: 1, maximum: 1})
      assert [:complete] == Helpers.create_actions([1, 2], [2], %{minimum: 1, ideal: 1, maximum: 2})
    end

    test "when the current_group is below ideal constraint, but equal or above minimum, add elements, then complete group" do
      assert [:add, :complete] == Helpers.create_actions([1], [2], %{minimum: 1, ideal: 2, maximum: 2})
      assert [:add, :complete] == Helpers.create_actions([1, 2], [3], %{minimum: 1, ideal: 3, maximum: 3})
    end

    test "when the current_group is at ideal constraint, but below the maximum constraint, complete, then add elements" do
      assert [:complete, :add] == Helpers.create_actions([1], [2], %{minimum: 1, ideal: 1, maximum: 2})
      assert [:complete, :add] == Helpers.create_actions([1, 2], [3], %{minimum: 1, ideal: 2, maximum: 3})
      assert [:complete, :add] == Helpers.create_actions([1, 2], [3], %{minimum: 2, ideal: 2, maximum: 3})
      assert [:complete, :add] == Helpers.create_actions([1, 2, 3], [4], %{minimum: 1, ideal: 3, maximum: 4})
      assert [:complete, :add] == Helpers.create_actions([1, 2, 3], [4], %{minimum: 2, ideal: 3, maximum: 4})
      assert [:complete, :add] == Helpers.create_actions([1, 2, 3], [4], %{minimum: 3, ideal: 3, maximum: 4})

      assert [:complete | add_actions] = Helpers.create_actions([1], [2, 3, 4], %{minimum: 1, ideal: 1, maximum: 2})
      assert add_actions <~> [:add, :add, :add]
    end

    test "there are no invalid inputs" do
      ptest [min: positive_int(), ideal: positive_int(), max: positive_int(), ungrouped: list(of: any(), min: 0, max: 10), current_group: list(of: any(), min: 0, max: 10)], repeat_for: 30 do
        Helpers.create_actions(current_group, ungrouped, %{minimum: min, ideal: ideal, maximum: max})
      end
    end
  end
end
