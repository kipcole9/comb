defmodule Comb.Base do
  def satisfy(parser, acceptor) do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        if acceptor.(term) do
          {:ok, term, rest}
        else
          {:error, :reject}
        end
      end
    end
  end

  def choice(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:error, :no_parsers}

        [first | rest] ->
          with {:error, _} <- first.(input) do
            choice(rest).(input)
          end
      end
    end
  end

  def sequence(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:ok, [], input}

        [initial | others] ->
          with {:ok, first, rest} <- initial.(input),
               {:ok, other, rest} <- sequence(others).(rest) do
            {:ok, [first | other], rest}
          end
      end
    end
  end

  def ignore(parser) do
    fn input ->
      with {:ok, _term, rest} <- parser.(input) do
        {:ok, [], rest}
      end
    end
  end

  def tag(parser, tag) do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        {:ok, {tag, term}, rest}
      end
    end
  end

  def optional(parser) do
    fn input ->
      case parser.(input) do
        {:ok, term, rest} -> {:ok, term, rest}
        {:error, _} -> {:ok, [], input}
      end
    end
  end

  def concat(parser, other_parser) do
    sequence([parser, other_parser])
  end

  def times(parser, options) do
  end

  def lookahead(parser, lookahead) when is_function(lookahead) do
    fn input ->
      with {:ok, term, rest} <- parser.(input),
           {:ok, _next_term, _other} <- lookahead.(rest) do
        {:ok, term, rest}
      end
    end
  end

  def lookahead(parser, lookahead) when is_binary(lookahead) do
    fn input ->
      with {:ok, term, rest} <- parser.(input),
           <<^lookahead, _remain::binary>> <- rest do
        {:ok, term, rest}
      end
    end
  end

  def lazy(combinator) do
    fn input ->
      parser = combinator.()
      parser.(input)
    end
  end

  def map(parser, mapper) when is_function(mapper) do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        {:ok, mapper.(term), rest}
      end
    end
  end

  def map(parser, {module, function, args}) do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        {:ok, apply(module, function, [term | args]), rest}
      end
    end
  end

  def repeat(parser) do
    fn input ->
      case parser.(input) do
        {:error, _reason} ->
          {:ok, [], input}

        {:ok, first, rest} ->
          {:ok, other, rest} = repeat(parser).(rest)
          {:ok, [first | other], rest}
      end
    end
  end
end
