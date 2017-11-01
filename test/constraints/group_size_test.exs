defmodule GroupSizeTest do
  use ExUnit.Case
  doctest Accomplice.Constraint.GroupSize

  alias Accomplice.Constraint.{GroupSize, GroupSizeError}

  describe "validate_args/1" do
    test "non-map args is invalid" do
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(nil) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args("") end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(1) end
    end

    test "any number of valid arguments can be supplied" do
      assert true == GroupSize.validate_args(%{minimum: 2})
      assert true == GroupSize.validate_args(%{ideal: 2})
      assert true == GroupSize.validate_args(%{maximum: 2})
      assert true == GroupSize.validate_args(%{})
    end

    test "args containing unknown key is invalid" do
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{unknown_arg: 3}) end
    end

    test "all GroupSize arg values must be integers" do
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: "binary", maximum: 2}) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 2, maximum: "binary"}) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 2, maximum: 3, ideal: "binary"}) end
    end

    test "minimum must be less than or equal to maximum" do
      assert true == GroupSize.validate_args(%{minimum: 2, maximum: 2})
      assert true == GroupSize.validate_args(%{minimum: 1, maximum: 2})
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 3, maximum: 2}) end
    end

    test "minimum and maxmimum cannot be less than 1" do
      assert true == GroupSize.validate_args(%{minimum: 1, maximum: 1})
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 0, maximum: 2}) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: -1, maximum: 2}) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 2, maximum: 0}) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 2, maximum: -1}) end
    end

    test "ideal must be between minimum and maximum inclusive" do
      assert true == GroupSize.validate_args(%{minimum: 1, ideal: 2, maximum: 3})
      assert true == GroupSize.validate_args(%{minimum: 1, ideal: 2, maximum: 2})
      assert true == GroupSize.validate_args(%{minimum: 1, ideal: 2, maximum: 2})
      assert true == GroupSize.validate_args(%{minimum: 2, ideal: 2, maximum: 2})
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 2, ideal: 1, maximum: 3}) end
      assert_raise GroupSizeError, fn -> GroupSize.validate_args(%{minimum: 2, ideal: 4, maximum: 3}) end
    end
  end

  describe "set_default_args/1" do
    test "does not alter args if minimum, ideal, and maximum are supplied" do
      assert GroupSize.set_default_args(%{minimum: 2, ideal: 3, maximum: 4, cats: 5}) ==
        %{minimum: 2, ideal: 3, maximum: 4, cats: 5}
    end

    test "sets minimum and ideal to 1 and maximum to 2 if no arguments are supplied" do
      assert GroupSize.set_default_args(%{}) == %{minimum: 1, ideal: 2, maximum: 2}
    end

    test "if no ideal is supplied, sets the ideal to the maximum" do
      assert GroupSize.set_default_args(%{minimum: 2, maximum: 3}) == %{minimum: 2, ideal: 3, maximum: 3}
    end

    test "sets the minimum to the lesser of ideal and maximum if minimum is missing" do
      assert GroupSize.set_default_args(%{ideal: 2, maximum: 3}) == %{minimum: 2, ideal: 2, maximum: 3}
      assert GroupSize.set_default_args(%{ideal: 3, maximum: 2}) == %{minimum: 2, ideal: 3, maximum: 2}
    end

    test "sets the maximum to the greater of ideal and minimum if maximum is missing" do
      assert GroupSize.set_default_args(%{minimum: 2, ideal: 3}) == %{minimum: 2, ideal: 3, maximum: 3}
      assert GroupSize.set_default_args(%{minimum: 3, ideal: 2}) == %{minimum: 3, ideal: 2, maximum: 3}
    end

    test "if only one argument is supplied, all arguments are set to the same value" do
      assert GroupSize.set_default_args(%{minimum: 2}) == %{minimum: 2, ideal: 2, maximum: 2}
      assert GroupSize.set_default_args(%{ideal: 2}) == %{minimum: 2, ideal: 2, maximum: 2}
      assert GroupSize.set_default_args(%{maximum: 2}) == %{minimum: 2, ideal: 2, maximum: 2}
    end
  end
end
