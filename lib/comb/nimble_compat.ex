defmodule Comb.NimbleCompat do
  import Comb.Base
  import Comb.Text.Ascii

  def ascii_char(chars) when is_list(chars) do
    Enum.map(chars, &char/1)
    |> choice()
  end

  defmacro reduce(parser, mapper) when is_atom(mapper) do
    quote do
      fn input ->
        with {:ok, term, rest} <- unquote(parser).(input) do
          {:ok, apply(unquote(__CALLER__.module), unquote(mapper), [term]), rest}
        end
      end
    end
  end

  def label(parser, _label) do
    parser
  end

  def replace(parser, replacement) do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        {:ok, term, rest}
      end
    end
  end
end