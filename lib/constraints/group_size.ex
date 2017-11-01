defmodule Accomplice.Constraint.GroupSize do

  alias Accomplice.Constraint.GroupSizeError

  def validate_args(args) when is_map(args) do
    unless unrecognized_arguments(args) |> Enum.empty? do
      raise GroupSizeError, message: unrecognized_arguments_error(args)
    end

    args = args |> set_default_args

    minimum = args[:minimum]
    maximum = args[:maximum]
    ideal = args[:ideal]

    if not is_nil(minimum) and not is_integer(minimum) do
      raise GroupSizeError, message: "Minimum GroupSize constraint argument must be an integer"
    end

    if not is_nil(maximum) and not is_integer(maximum) do
      raise GroupSizeError, message: "Maximum GroupSize constraint argument must be an integer"
    end

    if not is_nil(ideal) and not is_integer(ideal) do
      raise GroupSizeError, message: "Ideal GroupSize constraint argument must be an integer"
    end

    if minimum < 1 or maximum < 1 do
      raise GroupSizeError, message: "Minimum and Maximum must be greater than or equal to 1 in GroupSize constraint"
    end

    if minimum > maximum do
      raise GroupSizeError, message: "Minimum must be less than or equal to Maximum in GroupSize constraint"
    end

    if not is_nil(ideal) and ideal not in minimum..maximum do
      raise GroupSizeError, message: "Ideal must be between Minimum and Maximum inclusive"
    end

    true
  end
  def validate_args(_) do
    raise GroupSizeError, message: "GroupSize constraint args must be a map"
  end

  def set_default_args(args) when args == %{} do
    %{minimum: 1, ideal: 2, maximum: 2}
  end
  def set_default_args(%{minimum: _, ideal: _, maximum: _} = args), do: args
  def set_default_args(%{minimum: _minimum, maximum: maximum} = args) do
    args |> Map.put(:ideal, maximum)
  end
  def set_default_args(%{ideal: ideal, maximum: maximum} = args) do
    if ideal < maximum do
      args |> Map.put(:minimum, ideal)
    else
      args |> Map.put(:minimum, maximum)
    end
  end
  def set_default_args(%{minimum: minimum, ideal: ideal} = args) do
    if ideal > minimum do
      args |> Map.put(:maximum, ideal)
    else
      args |> Map.put(:maximum, minimum)
    end
  end
  def set_default_args(%{minimum: minimum} = args) do
    args |> Map.put(:ideal, minimum) |> Map.put(:maximum, minimum)
  end
  def set_default_args(%{ideal: ideal} = args) do
    args |> Map.put(:minimum, ideal) |> Map.put(:maximum, ideal)
  end
  def set_default_args(%{maximum: maximum} = args) do
    args |> Map.put(:minimum, maximum) |> Map.put(:ideal, maximum)
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
