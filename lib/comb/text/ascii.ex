defmodule Comb.Text.Ascii do
  import Comb.Base

  def char do
    fn input ->
      case input do
        "" -> {:error, :unexpected_end_of_string}
        <<char::binary-1, rest::binary>> -> {:ok, char, rest}
      end
    end
  end

  def char(expected) do
    satisfy(char(), fn char -> char == expected end)
  end

  defdelegate string(expected), to: Comb.Text.Unicode

  def digit do
    satisfy(char(), fn char -> char in ?0..?9 end)
  end

  def letter do
    satisfy(char(), fn char -> char in ?A..?Z or char in ?a..?z end)
  end

  def lower do
    satisfy(char(), fn char -> char in ?a..?z end)
  end

  def upper do
    satisfy(char(), fn char -> char in ?A..?Z end)
  end

  def whitespace do
    choice([char(?\s), char(?\n), char(?\t)])
    |> repeat()
  end

  def identifier_char do
    choice([letter(), char(?_), digit()])
  end

  def identifier do
    sequence([
      letter(),
      repeat(identifier_char()) |> satisfy(fn chars -> chars != [] end)
    ])
    |> map({List, :to_string, []})
  end

  def token(parser) do
    sequence([
      ignore(whitespace()),
      parser,
      ignore(whitespace())
    ])
  end
end
