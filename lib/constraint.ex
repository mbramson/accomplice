defmodule Accomplice.Constraint do
  defstruct type: :none, args: []

  alias Accomplice.Constraint

  @type t :: %Constraint{type: constraint_type(), args: any()}
  @type constraint_type :: :none | :group_size

  @doc """
  `Constraint.generate/2` accepts an atom representing the type of a
  constraint, and also arguments for that constraint.
  """
  @spec generate(atom, list(any)) :: t | {:error, :invalid_constraint_type}
  def generate(type, args) do
    with {:ok, valid_type} <- validate_constraint_type(type),
      do: %Constraint{type: valid_type, args: args}
  end

  @valid_constraint_types [:none, :group_size]

  @spec validate_constraint_type(atom) :: {:ok, constraint_type} | {:error, :invalid_constraint_type}
  defp validate_constraint_type(type) do
    if Enum.any?(@valid_constraint_types, &(&1 == type)) do
      {:ok, type}
    else
      {:error, :invalid_constraint_type}
    end
  end
end
