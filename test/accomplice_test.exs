defmodule AccompliceTest do
  use ExUnit.Case
  doctest Accomplice

  alias Accomplice.Constraint

  describe "group/2" do
    test "returns empty list when given an empty list" do
      assert Accomplice.group([], []) == []
    end

    test "when given a group_size constraint with a min and max of 1, returns appropriate values" do
      constraints = %{minimum: 1, maximum: 1}
      assert Accomplice.group([], constraints) == []
      assert Accomplice.group([1], constraints) == [[1]]
      assert Accomplice.group([1, 2], constraints) == [[1], [2]]
    end
  end
end
