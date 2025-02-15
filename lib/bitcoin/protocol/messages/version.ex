defmodule Bitcoin.Protocol.Messages.Version do
  @moduledoc """
    When a node creates an outgoing connection, it will immediately advertise its version.
    The remote node will respond with its version.
    No further communication is possible until both peers have exchanged their version.

    https://en.bitcoin.it/wiki/Protocol_documentation#version
  """

  alias Bitcoin.Protocol.Types.VarString
  alias Bitcoin.Protocol.Types.NetworkAddress

  # (int32_t) Identifies protocol version being used by the node
  defstruct version: 0,
            # (uint64_t) bitfield of features to be enabled for this connection
            services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
            # (int64_t) standard UNIX timestamp in seconds
            timestamp: 0,
            # The network address of the node receiving this message. - Bitcoin.Protocol.Types.NetworkAddress
            address_of_receiving_node: NetworkAddress,
            # versions 106 and greater, otherwise these fields do not exist
            # The network address of the node emitting this message. - Bitcoin.Protocol.Types.NetworkAddress
            address_of_sending_node: NetworkAddress,
            # (uint64_t) Node random nonce, randomly generated every time a version packet is sent. This nonce is used to detect connections to self.
            nonce: 0,
            # User Agent (0x00 if string is 0 bytes long)
            user_agent: "",
            # (int32_t) The last block received by the emitting node
            start_height: 0,
            # (bool) Whether the remote peer should announce relayed transactions or not, may be absent, see BIP 0037 <https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki>, since version >= 70001
            relay: false

  @type t :: %__MODULE__{
          version: non_neg_integer,
          services: bitstring,
          timestamp: non_neg_integer,
          address_of_receiving_node: NetworkAddress.t(),
          address_of_sending_node: NetworkAddress.t(),
          nonce: non_neg_integer,
          user_agent: binary,
          start_height: non_neg_integer,
          relay: boolean
        }

  @spec parse(binary) :: t
  def parse(data) do
    <<version::unsigned-little-integer-size(32), services::bitstring-size(64),
      timestamp::unsigned-little-integer-size(64), remaining::binary>> = data

    {address_of_receiving_node, remaining} = NetworkAddress.parse_version_stream(remaining)
    {address_of_sending_node, remaining} = NetworkAddress.parse_version_stream(remaining)

    <<nonce::unsigned-little-integer-size(64), remaining::binary>> = remaining

    {user_agent, remaining} = VarString.parse_stream(remaining)

    <<start_height::unsigned-little-integer-size(32), relay::binary>> = remaining

    # Relay may be absent, see https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki
    relay = relay == <<1>>

    %__MODULE__{
      version: version,
      services: services,
      timestamp: timestamp,
      address_of_receiving_node: address_of_receiving_node,
      address_of_sending_node: address_of_sending_node,
      nonce: nonce,
      user_agent: user_agent,
      start_height: start_height,
      relay: relay
    }
  end

  @spec serialize(t) :: binary
  def serialize(%__MODULE__{} = s) do
    <<
      s.version::unsigned-little-integer-size(32),
      s.services::bitstring-size(64),
      s.timestamp::unsigned-little-integer-size(64)
    >> <>
      NetworkAddress.serialize_version(s.address_of_receiving_node) <>
      NetworkAddress.serialize_version(s.address_of_sending_node) <>
      <<
        s.nonce::unsigned-little-integer-size(64)
      >> <>
      VarString.serialize(s.user_agent) <>
      <<
        s.start_height::unsigned-little-integer-size(32),
        if(s.relay, do: 1, else: 0)
      >>
  end
end
