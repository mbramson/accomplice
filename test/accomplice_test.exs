defmodule AccompliceTest do
  use ExUnit.Case
  doctest Accomplice

  describe "group/2" do
    test "returns empty list when given an empty list" do
      assert Accomplice.group([], []) == []
    end

  end
end
