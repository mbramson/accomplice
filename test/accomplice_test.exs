defmodule AccompliceTest do
  use ExUnit.Case
  doctest Accomplice

  alias Accomplice.Constraint

  describe "group/2" do
    test "returns empty list when given an empty list" do
      assert Accomplice.group([], []) == []
    end

    test "when given a group_size constraint with a min and max of 1, returns appropriate values" do
      constraint = %Constraint{type: :group_size, args: %{minimum: 1, ideal: 1, maximum: 1}}
      assert Accomplice.group([], [constraint]) == []
      assert Accomplice.group([1], [constraint]) == [[1]]
      assert Accomplice.group([1, 2], [constraint]) == [[1], [2]]
    end
  end
end
