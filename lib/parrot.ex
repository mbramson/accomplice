defmodule Parrot do
  @moduledoc """
  Documentation for Parrot.
  """

  @doc """
  `Parrot.group/2` accepts a list of unordered elements and produces a list of
  groups of those elements subjected to the passed in constraints.
  """
  @spec group(list(any()), list(Constraint.t)) :: list(any())
  def group(elements, constraints) do
    []
  end
end
