defmodule Accomplice.Constraint.GroupSize do

  alias Accomplice.Constraint.GroupSizeError

  def validate_args(args) when args == %{} do
    raise GroupSizeError, message: "No arguments were supplied to a GroupSize constraint"
  end
  def validate_args(args) when is_map(args) do
    unless unrecognized_arguments(args) |> Enum.empty? do
      raise GroupSizeError, message: unrecognized_arguments_error(args)
    end
    minimum = args[:minimum]
    maximum = args[:maximum]
    ideal = args[:ideal]
  end
  def validate_args(_) do
    raise GroupSizeError, message: "GroupSize constraint args must be a map"
  end

  @valid_arg_keys [:minimum, :maximum, :ideal]

  def unrecognized_arguments(args) do
    args
    |> Map.keys
    |> Enum.filter(&(!Enum.member?(@valid_arg_keys, &1)))
  end

  defp unrecognized_arguments_error(args) do
    unrecognized_args = args |> unrecognized_arguments
    """
    Invalid argument supplied to a GroupSize constraint.
    
    Allowed argument keys are :minimum, :maximum, and :ideal.

    The following unrecognized arguments keys were supplied: #{inspect unrecognized_args}
    """
  end
end


defmodule Accomplice.Constraint.GroupSizeError do
  defexception message: "Invalid GroupSize Constraint"
end
