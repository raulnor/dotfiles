#!/usr/bin/env elixir

defmodule FizzBuzz do
    @moduledoc """
    FizzBuzz as an example of why function pattern matching is good and bad.

    - Order matters. rem(x, 15) must come first.
    - Functions like Integer.mod/2 cannot go in guards. rem/2 used instead.
    - Complex cases still have to go inside function bodies.

    Pattern matches save you one or two indentations. That's not nothing.
    """

    defp convert_integer(x) when rem(x, 15) == 0, do: "FizzBuzz"
    defp convert_integer(x) when rem(x, 3) == 0, do: "Fizz"
    defp convert_integer(x) when rem(x, 5) == 0, do: "Buzz"
    defp convert_integer(x), do: Integer.to_string(x)

    def convert(x) when is_integer(x), do: convert_integer(x)
    def convert(x) when is_binary(x) do
      case Integer.parse(x) do
        {i, ""} -> convert_integer(i)
        _ -> x
      end
    end
    def convert(x), do: x
end

# __main__
System.argv() |> Enum.map(&FizzBuzz.convert/1) |> Enum.join("\n") |> IO.puts()
