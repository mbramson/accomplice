defmodule AccompliceTest do
  use ExUnit.Case
  doctest Accomplice

  import OrderInvariantCompare

  describe "group/2" do
    test "returns empty list when given an empty list" do
      assert Accomplice.group([], []) == []
    end

    test "when given a group_size constraint with a min and max of 1, returns appropriate values" do
      constraints = %{minimum: 1, maximum: 1}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]
      assert Accomplice.group([1, 2], constraints) <~> [[1], [2]]
      assert Accomplice.group([1, 2, 3], constraints) <~> [[1], [2], [3]]
    end

    test "when given a group_size constraint with a min and max of 2, returns appropriate values" do
      constraints = %{minimum: 2, maximum: 2}
      assert Accomplice.group([], constraints) == []

      grouping = Accomplice.group([1, 2], constraints)
      assert length(grouping) == 1
      assert Enum.at(grouping, 0) <~> [1, 2]

      grouping = Accomplice.group([1, 2, 3, 4], constraints)
      assert length(grouping) == 2
      assert grouping |> Enum.at(0) |> length == 2
      assert grouping |> Enum.at(1) |> length == 2

      grouping = Accomplice.group([1, 2, 3, 4, 5, 6], constraints)
      assert length(grouping) == 3
      assert grouping |> Enum.at(0) |> length == 2
      assert grouping |> Enum.at(1) |> length == 2
      assert grouping |> Enum.at(2) |> length == 2
    end
  end
end
