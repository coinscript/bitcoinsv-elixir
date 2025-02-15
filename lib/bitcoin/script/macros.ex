defmodule Bitcoin.Script.Macros do
  # `op` macro is just a shorthand for defining another case of the `run` function.
  #
  #     op :OP_DUP, [x | stack], do: [x, x | stack]
  #
  # expands to
  #
  #     run([x | stack], [:OP_DUP | script], opts), do: [x, x | stack] |> run(script, opts)

  # make it possible to provide a guard
  defmacro op(op, {:when, _, [stack_clause, when_clause]}, do: stack_expression)
           when is_atom(op) do
    quote do
      def run(unquote(stack_clause), [unquote(op) | script], opts) when unquote(when_clause) do
        unquote(stack_expression) |> run(script, opts)
      end
    end
  end

  defmacro op(op, stack_clause, do: stack_expression) when is_atom(op) do
    quote do
      def run(unquote(stack_clause), [unquote(op) | script], opts) do
        unquote(stack_expression) |> run(script, opts)
      end
    end
  end

  # when another argument is provided, it receives run opts
  defmacro op(op, stack_clause, opts, do: stack_expression) when is_atom(op) do
    quote do
      def run(unquote(stack_clause), [unquote(op) | script], unquote(opts)) do
        unquote(stack_expression) |> run(script, unquote(opts))
      end
    end
  end

  # Nested macros, anyone?

  # `op_num` macro is like `op`, but casts arguments to numbers and serializes output to script integer
  #
  #     op_num :OP_ADD, a, b, do: a + b
  #
  # expands to
  #
  #     run([a, b | stack], [:OP_ADD | script], opts), do: [bin(num(a) + num(b)) | stack] |> run(script, opts)
  #
  # small update: we additionally check if num returns a number (it may return :error for invalid int encoding)

  defmacro op_num(op, a, do: stack_expression) when is_atom(op) do
    quote do
      def run([unquote(a) | stack], [unquote(op) | script], opts) do
        with unquote(a) when is_number(unquote(a)) <- num(unquote(a), opts),
             do: [bin(unquote(stack_expression)) | stack] |> run(script, opts)
      end
    end
  end

  defmacro op_num(op, a, b, do: stack_expression) when is_atom(op) do
    quote do
      def run([unquote(a), unquote(b) | stack], [unquote(op) | script], opts) do
        with unquote(a) when is_number(unquote(a)) <- num(unquote(a), opts),
             unquote(b) when is_number(unquote(b)) <- num(unquote(b), opts),
             do: [bin(unquote(stack_expression)) | stack] |> run(script, opts)
      end
    end
  end

  defmacro op_num(op, a, b, c, do: stack_expression) when is_atom(op) do
    quote do
      def run([unquote(a), unquote(b), unquote(c) | stack], [unquote(op) | script], opts) do
        with unquote(a) when is_number(unquote(a)) <- num(unquote(a), opts),
             unquote(b) when is_number(unquote(b)) <- num(unquote(b), opts),
             unquote(c) when is_number(unquote(c)) <- num(unquote(c), opts),
             do: [bin(unquote(stack_expression)) | stack] |> run(script, opts)
      end
    end
  end

  # `op_hash` macro is like `op`, but makes sure input is binary and handles special case of empty stack
  #
  #     op_hash :OP_SHA1, x, do: :crypto.hash(:sha, x)
  #
  # expands to
  #
  #     run([], [:OP_SHA1 | _script] = script, opts), do: run([""], script, opts)
  #     run([x | stack], [:OP_SHA1 | script], opts), do: x = bin(x); [:crypto.hash(:sha, x) | stack] |> run(script, opts)

  defmacro op_hash(op, a, do: stack_expression) when is_atom(op) do
    quote do
      def run([], [unquote(op) | _script] = script, opts) do
        run([""], script, opts)
      end

      def run([unquote(a) | stack], [unquote(op) | script], opts) do
        unquote(a) = bin(unquote(a))
        [unquote(stack_expression) | stack] |> run(script, opts)
      end
    end
  end

  # changes opcode in the script to list of provided opcodes

  defmacro op_alias(op, list) when is_atom(op) and is_list(list) do
    quote do
      def run(stack, [unquote(op) | script], opts) do
        stack |> run(unquote(list) ++ script, opts)
      end
    end
  end

  # `op_push` puts a specified value on the stack
  #
  #     op_const :OP_7, 7 |> bin
  #
  # expands to
  #
  #     run(stack, [:OP_7 | script], opts), do: [(7 |> bin) | stack] |> run(script, opts)

  defmacro op_push(op, value) when is_atom(op) do
    quote do
      def run(stack, [unquote(op) | script], opts) do
        [unquote(value) | stack] |> run(script, opts)
      end
    end
  end
end
