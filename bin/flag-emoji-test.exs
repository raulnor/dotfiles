#! /usr/bin/env elixir
# TL 11/19/25 - https://www.hackingwithswift.com/articles/280/one-swift-mistake-everyone-should-stop-making-today

ca_us = "🇨🇦🇺🇸"
ca = "🇨🇦"
us = "🇺🇸"
au = "🇦🇺"
ni = "🇳🇮"

IO.puts("#{ca_us} contains #{ca}: #{String.contains?(ca_us, ca)}")
IO.puts("#{ca_us} contains #{us}: #{String.contains?(ca_us, us)}")
IO.puts("#{ca_us} contains #{au}: #{String.contains?(ca_us, au)}")

# String test

string_t = String.replace(ca_us, au, ni)
cn = "🇨🇳"
is = "🇮🇸"

IO.puts("String.replace(#{ca_us}, #{au}, #{ni}): #{string_t}")
IO.puts("#{string_t} contains #{ca}: #{String.contains?(string_t, ca)}")
IO.puts("#{string_t} contains #{us}: #{String.contains?(string_t, us)}")
IO.puts("#{string_t} contains #{cn}: #{String.contains?(string_t, cn)}")
IO.puts("#{string_t} contains #{is}: #{String.contains?(string_t, is)}")

defmodule Grapheme do
  def replace(string, pattern, replacement) do
    string_graphemes = String.graphemes(string)
    pattern_graphemes = String.graphemes(pattern)
    replacement_graphemes = String.graphemes(replacement)

    replace_subsequence(string_graphemes, pattern_graphemes, replacement_graphemes)
    |> Enum.join()
  end

  defp replace_subsequence(list, pattern, replacement) do
    pattern_length = length(pattern)

    case list do
      [] -> []
      _ ->
        if List.starts_with?(list, pattern) do
          replacement ++ replace_subsequence(Enum.drop(list, pattern_length), pattern, replacement)
        else
          [hd(list) | replace_subsequence(tl(list), pattern, replacement)]
        end
    end
  end
end

# Grapheme test (single)

grapheme_t = Grapheme.replace(ca_us, au, ni)

IO.puts("Grapheme.replace(#{ca_us}, #{au}, #{ni}): #{grapheme_t}")
IO.puts("#{grapheme_t} contains #{ca}: #{String.contains?(grapheme_t, ca)}")
IO.puts("#{grapheme_t} contains #{us}: #{String.contains?(grapheme_t, us)}")
IO.puts("#{grapheme_t} contains #{cn}: #{String.contains?(grapheme_t, cn)}")
IO.puts("#{grapheme_t} contains #{is}: #{String.contains?(grapheme_t, is)}")

# Grapheme test (multiple)

ca_us_us = "🇨🇦🇺🇸🇺🇸"
us_us = "🇺🇸🇺🇸"
IO.puts("Grapheme.replace(#{ca_us_us}, #{us_us}, #{us}): #{Grapheme.replace(ca_us_us, us_us, us)}")
