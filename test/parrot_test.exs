defmodule ParrotTest do
  use ExUnit.Case
  doctest Parrot

  describe "group/2" do
    test "returns empty list when given an empty list" do
      assert Parrot.group([], []) == []
    end

  end
end
