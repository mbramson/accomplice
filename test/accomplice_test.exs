defmodule AccompliceTest do
  use ExUnit.Case
  doctest Accomplice

  import OrderInvariantCompare # for <~> operator

  def grouping_is(grouping, expected_grouping) when is_list(grouping) do
    group_counts = Enum.map(grouping, fn element -> length(element) end)
    group_counts <~> expected_grouping
  end

  describe "group/2 for simple groupings with only min and max constraints" do
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
      assert grouping |> grouping_is([2])

      grouping = Accomplice.group([1, 2, 3, 4], constraints)
      assert grouping |> grouping_is([2, 2])

      grouping = Accomplice.group([1, 2, 3, 4, 5, 6], constraints)
      assert grouping |> grouping_is([2, 2, 2])
    end

    test "when given a group_size constraint with a min and max of 2, and odd length list, errors" do
      constraints = %{minimum: 2, maximum: 2}
      assert Accomplice.group([1], constraints) == {:error, :group_size_below_minimum}
      assert Accomplice.group([1, 2, 3], constraints) == {:error, :group_size_below_minimum}
      assert Accomplice.group([1, 2, 3, 4, 5], constraints) == {:error, :group_size_below_minimum}
    end

    test "when given a group_size constraint with a min of 1 and max of 2, returns appropriate values" do
      constraints = %{minimum: 1, maximum: 2}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]

      grouping = Accomplice.group([1, 2], constraints)
      assert grouping |> grouping_is([2])

      grouping = Accomplice.group([1, 2, 3], constraints)
      assert grouping |> grouping_is([2, 1])

      grouping = Accomplice.group([1, 2, 3, 4], constraints)
      assert grouping |> grouping_is([2, 2])

      grouping = Accomplice.group([1, 2, 3, 4, 5], constraints)
      assert grouping |> grouping_is([2, 2, 1])
    end

    test "when given a group_size constraint with a min of 1 and max of 3, returns appropriate values" do
      constraints = %{minimum: 1, maximum: 3}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]

      grouping = Accomplice.group([1, 2], constraints)
      assert grouping |> grouping_is([2])

      grouping = Accomplice.group([1, 2, 3], constraints)
      assert grouping |> grouping_is([3])

      grouping = Accomplice.group([1, 2, 3, 4], constraints)
      assert grouping |> grouping_is([3, 1])
    end

    test "when given a group_size constraint with a min of 2 and max of 3, returns appropriate values" do
      constraints = %{minimum: 2, maximum: 3}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == {:error, :group_size_below_minimum}

      grouping = Accomplice.group([1, 2], constraints)
      assert grouping |> grouping_is([2])

      grouping = Accomplice.group([1, 2, 3], constraints)
      assert grouping |> grouping_is([3])

      grouping = Accomplice.group([1, 2, 3, 4], constraints)
      assert grouping |> grouping_is([2, 2])

      grouping = Accomplice.group([1, 2, 3, 4, 5], constraints)
      assert grouping |> grouping_is([3, 2])

      grouping = Accomplice.group([1, 2, 3, 4, 5, 6], constraints)
      assert grouping |> grouping_is([3, 3])

      grouping = Accomplice.group([1, 2, 3, 4, 5, 6, 7], constraints)
      assert grouping |> grouping_is([3, 2, 2])
    end
  end
end
