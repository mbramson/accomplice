defmodule ConstraintTest do
  use ExUnit.Case
  doctest Accomplice

  alias Accomplice.Constraint
  import Accomplice.Constraint

  describe "generate/2" do
    test "returns an error tuple when generating an invalid constraint type" do
      assert generate(:unknown_type, []) == {:error, :invalid_constraint_type}
    end

    test "can generate a group_size constraint" do
      assert generate(:group_size, []) == %Constraint{type: :group_size, args: []}
    end
  end
end
