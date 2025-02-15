defmodule Bitcoin.Protocol.Messages.PongTest do
  use ExUnit.Case
  alias Bitcoin.Protocol.Messages.Pong

  test "parses the ping message" do
    nonce = 123_456_790_987_654_321

    # 64 bit int nonce
    payload = <<177, 196, 237, 27, 76, 155, 182, 1>>

    struct = %Pong{nonce: nonce}

    assert Pong.parse(payload) == struct
    assert Pong.serialize(struct) == payload
  end
end
