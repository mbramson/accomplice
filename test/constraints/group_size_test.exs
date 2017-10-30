defmodule GroupSizeTest do
  use ExUnit.Case
  doctest Parrot.Constraint.GroupSize

  alias Parrot.Constraint.{GroupSize, GroupSizeError}

  describe "validate_args/1" do
    test "empty map is invalid" do
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{}) end
    end

    test "non-map args is invalid" do
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(nil) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args("") end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(1) end
    end

    test "args containing unknown key is invalid" do
      assert_raise GroupSizeError, fn ->
        GroupSize.validate_args(%{unknown_arg: 3})
      end
    end

    test "minimum must be less than or equal to maximum" do

    end

    test "ideal must be between minimum and maximum" do

    end
  end
end
