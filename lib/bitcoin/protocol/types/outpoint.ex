defmodule Bitcoin.Protocol.Types.Outpoint do
  # char[32] - The hash of the referenced transaction.
  defstruct hash:
              <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0>>,
            # The index of the specific output in the transaction. The first output is 0, etc.
            index: 0

  @type t :: %__MODULE__{
          hash: Bitcoin.Tx.t_hash(),
          index: non_neg_integer
        }

  # defimpl Inspect, for: __MODULE__ do
  #   def inspect(data, _opts) do
  #     "%Outpoint{ ##{data.index} hash: #{data.hash |> Base.encode16} }"
  #   end
  # end

  @spec parse_stream(binary) :: {t, binary}
  def parse_stream(
        <<hash::bytes-size(32), index::unsigned-little-integer-size(32), remainder::binary>>
      ) do
    {%__MODULE__{
       hash: hash,
       index: index
     }, remainder}
  end

  @spec parse(binary) :: t
  def parse(<<hash::bytes-size(32), index::unsigned-little-integer-size(32)>>) do
    %__MODULE__{
      hash: hash,
      index: index
    }
  end

  @spec serialize(t) :: binary
  def serialize(%__MODULE__{} = s) do
    <<
      s.hash::bytes-size(32),
      s.index::unsigned-little-integer-size(32)
    >>
  end

  @doc """
  Find the correct private key for Outpoint, from key list.
  """
  def find_priv_key(%__MODULE__{} = s, keys) do
  end
end
