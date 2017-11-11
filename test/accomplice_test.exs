defmodule AccompliceTest do
  use ExUnit.Case
  doctest Accomplice

  import OrderInvariantCompare # for <~> operator

  def grouping_is(grouping, expected_grouping) when is_list(grouping) do
    group_counts = Enum.map(grouping, fn element -> length(element) end)
    unless group_counts <~> expected_grouping do
      flunk("expected grouping of #{inspect expected_grouping} \ngot grouping of      #{inspect group_counts}")
    end
  end

  describe "group/2 for simple groupings with only min and max constraints" do
    test "returns empty list when given an empty list" do
      assert Accomplice.group([], %{}) == []
      assert Accomplice.group([], %{minimum: 1, maximum: 1}) == []
      assert Accomplice.group([], %{minimum: 1, maximum: 2}) == []
      assert Accomplice.group([], %{minimum: 2, maximum: 2}) == []
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

      Accomplice.group([1, 2], constraints)             |> grouping_is([2])
      Accomplice.group([1, 2, 3, 4], constraints)       |> grouping_is([2, 2])
      Accomplice.group([1, 2, 3, 4, 5, 6], constraints) |> grouping_is([2, 2, 2])
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

      Accomplice.group([1, 2], constraints)          |> grouping_is([2])
      Accomplice.group([1, 2, 3], constraints)       |> grouping_is([2, 1])
      Accomplice.group([1, 2, 3, 4], constraints)    |> grouping_is([2, 2])
      Accomplice.group([1, 2, 3, 4, 5], constraints) |> grouping_is([2, 2, 1])
    end

    test "when given a group_size constraint with a min of 1 and max of 3, returns appropriate values" do
      constraints = %{minimum: 1, maximum: 3}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]

      Accomplice.group([1, 2], constraints)       |> grouping_is([2])
      Accomplice.group([1, 2, 3], constraints)    |> grouping_is([3])
      Accomplice.group([1, 2, 3, 4], constraints) |> grouping_is([3, 1])
    end

    test "when given a group_size constraint with a min of 2 and max of 3, returns appropriate values" do
      constraints = %{minimum: 2, maximum: 3}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == {:error, :group_size_below_minimum}

      Accomplice.group([1, 2], constraints)                |> grouping_is([2])
      Accomplice.group([1, 2, 3], constraints)             |> grouping_is([3])
      Accomplice.group([1, 2, 3, 4], constraints)          |> grouping_is([2, 2])
      Accomplice.group([1, 2, 3, 4, 5], constraints)       |> grouping_is([3, 2])
      Accomplice.group([1, 2, 3, 4, 5, 6], constraints)    |> grouping_is([3, 3])
      Accomplice.group([1, 2, 3, 4, 5, 6, 7], constraints) |> grouping_is([3, 2, 2])
    end
  end

  describe "group/2 with an ideal constraint" do
    test "returns empty list when given an empty list" do
      assert Accomplice.group([], %{ideal: 1}) == []
      assert Accomplice.group([], %{minimum: 1, ideal: 1, maximum: 1}) == []
    end

    test "with a group_size constraint with a min, ideal, and max of 1, returns appropriate values" do
      constraints = %{minimum: 1, ideal: 1, maximum: 1}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]
      assert Accomplice.group([1, 2], constraints) <~> [[1], [2]]
      assert Accomplice.group([1, 2, 3], constraints) <~> [[1], [2], [3]]
    end

    test "with a group_size constraint with a min, ideal, and max of 2, returns appropriate values" do
      constraints = %{minimum: 2, ideal: 2, maximum: 2}
      assert Accomplice.group([], constraints) == []

      Accomplice.group([1, 2], constraints)             |> grouping_is([2])
      Accomplice.group([1, 2, 3, 4], constraints)       |> grouping_is([2, 2])
      Accomplice.group([1, 2, 3, 4, 5, 6], constraints) |> grouping_is([2, 2, 2])
    end

    test "with a group_size constraint with a min of 1 and ideal, max of 2, returns appropriate values" do
      constraints = %{minimum: 1, ideal: 2, maximum: 2}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]

      Accomplice.group([1, 2], constraints)          |> grouping_is([2])
      Accomplice.group([1, 2, 3], constraints)       |> grouping_is([2, 1])
      Accomplice.group([1, 2, 3, 4], constraints)    |> grouping_is([2, 2])
      Accomplice.group([1, 2, 3, 4, 5], constraints) |> grouping_is([2, 2, 1])
    end

    test "with a group_size constraint with a min, ideal of 1 and max of 2, returns appropriate values" do
      constraints = %{minimum: 1, ideal: 1, maximum: 2}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]

      Accomplice.group([1, 2], constraints)    |> grouping_is([1, 1])
      Accomplice.group([1, 2, 3], constraints) |> grouping_is([1, 1, 1])
    end

    test "with a group_size constraint with a min, ideal of 2 and max of 3, returns appropriate values" do
      constraints = %{minimum: 2, ideal: 2, maximum: 3}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == :impossible

      Accomplice.group([1, 2], constraints)             |> grouping_is([2])
      Accomplice.group([1, 2, 3], constraints)          |> grouping_is([3])
      Accomplice.group([1, 2, 3, 4], constraints)       |> grouping_is([2, 2])
      Accomplice.group([1, 2, 3, 4, 5], constraints)    |> grouping_is([3, 2])
      Accomplice.group([1, 2, 3, 4, 5, 6], constraints) |> grouping_is([2, 2, 2])
    end

    test "with a group_size constraint with a min of 2, ideal of 3 and max of 4, returns appropriate values" do
      constraints = %{minimum: 2, ideal: 3, maximum: 4}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == :impossible

      Accomplice.group([1, 2], constraints)             |> grouping_is([2])
      Accomplice.group([1, 2, 3], constraints)          |> grouping_is([3])
      Accomplice.group([1, 2, 3, 4], constraints)       |> grouping_is([4]) # [2, 2] also acceptable
      Accomplice.group([1, 2, 3, 4, 5], constraints)    |> grouping_is([3, 2])
      Accomplice.group([1, 2, 3, 4, 5, 6], constraints) |> grouping_is([3, 3])
    end
  end
end
