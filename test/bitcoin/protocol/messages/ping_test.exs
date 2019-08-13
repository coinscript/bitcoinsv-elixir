defmodule Bitcoin.Protocol.Messages.PingTest do
  use ExUnit.Case
  alias Bitcoin.Protocol.Messages.Ping

  test "parses the ping message" do
    nonce = 123_456_790_987_654_321

    # 64 bit int nonce
    payload = <<177, 196, 237, 27, 76, 155, 182, 1>>

    struct = %Ping{nonce: nonce}

    assert Ping.parse(payload) == struct
    assert Ping.serialize(struct) == payload
  end
end
