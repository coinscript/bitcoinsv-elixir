defmodule Bitcoin.Protocol.Messages.Pong do
  @moduledoc """
    The pong message is sent in response to a ping message. In modern protocol versions, a pong response is generated
    using a nonce included in the ping.

    https://en.bitcoin.it/wiki/Protocol_specification#pong
  """

  # nonce from received ping
  defstruct nonce: 0

  @type t :: %__MODULE__{
          nonce: non_neg_integer
        }

  @spec parse(binary) :: t
  def parse(<<nonce::unsigned-little-integer-size(64)>>) do
    %__MODULE__{
      nonce: nonce
    }
  end

  @spec serialize(t) :: binary
  def serialize(%__MODULE__{} = s) do
    <<
      s.nonce::unsigned-little-integer-size(64)
    >>
  end
end
