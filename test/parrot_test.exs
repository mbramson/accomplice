defmodule ParrotTest do
  use ExUnit.Case
  doctest Parrot

  test "greets the world" do
    assert Parrot.hello() == :world
  end
end
