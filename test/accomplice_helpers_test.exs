defmodule AccompliceHelpersTest do
  use ExUnit.Case
  use Quixir

  alias Accomplice.Helpers

  describe "validate_options/1" do
    test "options must be map" do
      assert {:error, :options_is_not_map} == Helpers.validate_options([])
      assert {:error, :options_is_not_map} == Helpers.validate_options(nil)
      assert {:error, :options_is_not_map} == Helpers.validate_options("")
    end

    test "missing size constraints is invalid" do
      assert {:error, :missing_size_constraint} == Helpers.validate_options(%{})
      assert {:error, :missing_size_constraint} == Helpers.validate_options(%{minimum: 1})
      assert {:error, :missing_size_constraint} == Helpers.validate_options(%{maximum: 1})
    end

    test "size constraints must be greater than zero" do
      assert {:error, :size_constraint_below_one} == Helpers.validate_options(%{minimum: 0, maximum: 1})
      assert {:error, :size_constraint_below_one} == Helpers.validate_options(%{minimum: 1, maximum: 0})
      assert {:error, :size_constraint_below_one} == Helpers.validate_options(%{minimum: 1, ideal: 0, maximum: 1})
      assert {:error, :size_constraint_below_one} == Helpers.validate_options(%{minimum: 1, ideal: 1, maximum: 0})
      assert {:error, :size_constraint_below_one} == Helpers.validate_options(%{minimum: 0, ideal: 1, maximum: 1})
      assert %{} = Helpers.validate_options(%{minimum: 1, maximum: 1})
      assert %{} = Helpers.validate_options(%{minimum: 1, ideal: 1, maximum: 1})
    end

    test "min cannot be greater than max" do
      assert {:error, :minimum_above_maximum} == Helpers.validate_options(%{minimum: 2, maximum: 1})
    end

    test "ideal must be between min and max" do
      assert {:error, :ideal_not_between_min_and_max} == Helpers.validate_options(%{minimum: 2, ideal: 1, maximum: 3})
      assert {:error, :ideal_not_between_min_and_max} == Helpers.validate_options(%{minimum: 2, ideal: 4, maximum: 3})
    end
  end

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
      assert [:add] == Helpers.create_actions([], [1, 2], %{minimum: 1, ideal: 1, maximum: 1})
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

      assert [:complete, :add] = Helpers.create_actions([1], [2, 3, 4], %{minimum: 1, ideal: 1, maximum: 2})
    end

    test "there are no invalid inputs" do
      ptest [min: positive_int(), ideal: positive_int(), max: positive_int(), ungrouped: list(of: any(), min: 0, max: 10), current_group: list(of: any(), min: 0, max: 10)], repeat_for: 30 do
        Helpers.create_actions(current_group, ungrouped, %{minimum: min, ideal: ideal, maximum: max})
      end
    end
  end
  describe "generate_memo_key/2" do
    test "returns a string representing the passed in data" do
      ptest [current_group: list(of: any(), max: 10), ungrouped: list(of: any(), max: 10)], repeat_for: 30 do
        Helpers.generate_memo_key(current_group, ungrouped)
      end
    end

    test "returns the same memo_key even if elements are in different orders" do
      assert Helpers.generate_memo_key([1,2,3,4], [5,6,7,8]) ==
             Helpers.generate_memo_key([3,2,1,4], [8,5,7,6])
    end
  end
end
