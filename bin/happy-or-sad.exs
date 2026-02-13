#! /usr/bin/env elixir
# TL 10/26/23 - Daily code based on https://leancrew.com/all-this/2023/10/happy-and-sad/
# % time happy-or-sad.exs 1
#   happy
#   happy-or-sad.exs 1  0.29s user 0.31s system 196% cpu 0.304 total
# Not sure I like the startup time or the .exs

defmodule Number do
  def sum_of_squares_of_digits(number) when number >= 0 do
    sum_of_squares_of_digits(number, 0)
  end

  defp sum_of_squares_of_digits(0, acc), do: acc
  defp sum_of_squares_of_digits(number, acc) when number > 0 do
    digit = rem(number, 10)
    sum_of_squares_of_digits(div(number, 10), acc + digit * digit)
  end

  def happy_or_sad(number) do
    z = sum_of_squares_of_digits(number)
    case z do
      1 -> "happy"
      4 -> "sad"
      16 -> "sad"
      37 -> "sad"
      58 -> "sad"
      89 -> "sad"
      145 -> "sad"
      42 -> "sad"
      20 -> "sad"
      _ -> happy_or_sad(z)
    end
  end
end

arg = hd(System.argv())
number = String.to_integer(arg)
number |> Number.happy_or_sad() |> IO.puts()
