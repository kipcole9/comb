defmodule Comb.Text.Unicode do
  import Comb.Base
  import Unicode.Set, only: [match?: 2]
  import Kernel, except: [match?: 2]

  def char do
    fn input ->
      case input do
        "" -> {:error, :unexpected_end_of_string}
        <<char::utf8, rest::binary>> -> {:ok, char, rest}
      end
    end
  end

  def char(expected) do
    satisfy(char(), fn char -> char == expected end)
  end

  def string(expected) do
    fn input ->
      case input do
        <<^expected, rest::binary>> -> {:ok, expected, rest}
        _other -> {:error, :not_found}
      end
    end
  end

  def digit do
    satisfy(char(), fn
      char when match?(char, "[:Nd:]") -> true
      _ -> false
    end)
  end

  def letter do
    satisfy(char(), fn
      char when match?(char, "[:L:]") -> true
      _ -> false
    end)
  end

  def lower do
    satisfy(char(), fn
      char when match?(char, "[:Ll:]") -> true
      _ -> false
    end)
  end

  def upper do
    satisfy(char(), fn
      char when match?(char, "[:Lu:]") -> true
      _ -> false
    end)
  end

  def whitespace_char do
    satisfy(char(), fn
      char when match?(char, "[[:Zs:]\r\n\t]") -> true
      _ -> false
    end)
  end

  def whitespace do
    repeat(whitespace_char())
  end

  def xid_start do
    satisfy(char(), fn
      char when match?(char, "[:xid_start:]") -> true
      _ -> false
    end)
  end

  def xid_continue do
    satisfy(char(), fn
      char when match?(char, "[:xid_continue:]") -> true
      _ -> false
    end)
  end

  def identifier do
    sequence([
      xid_start(),
      repeat(xid_continue()) |> satisfy(fn chars -> chars != [] end)
    ])
    |> map({List, :to_string, []})
  end

  def plus do
    choice([
      char(0x2B),
      char(0xFE62),
      char(0xFF0B),
      char(0x2795)
    ])
  end

  def minus do
    choice([
      char(0x2D),
      char(0xFE63),
      char(0xFF0D),
      char(0x2796)
    ])
  end

  def sign do
    choice([plus(), minus()])
  end

  def integer do
    sequence([
      optional(sign()),
      digit(),
      repeat(digit())
    ])
    |> map(&:erlang.iolist_to_binary/1)
  end
end
