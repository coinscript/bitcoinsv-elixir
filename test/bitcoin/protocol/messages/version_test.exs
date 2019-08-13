defmodule Bitcoin.Protocol.Messages.VersionTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Messages.Version

  test "parses the version payload for version 0.3.19" do
    # 31900 (version 0.3.19)
    payload =
      Base.decode16!(
        # 1 (NODE_NETWORK services)
        # Mon Dec 20 21:50:14 EST 2010 . 1292899814 Unix Epoch
        # Recipient address info - see Network Address
        # Sender address info - see Network Address
        # Node random unique ID
        # "" sub-version string (string is 0 bytes long)
        # Last block sending node has is block #98645
        "9C7C0000" <>
          "0100000000000000" <>
          "E615104D00000000" <>
          "010000000000000000000000000000000000FFFF0A000001208D" <>
          "010000000000000000000000000000000000FFFF0A000002208D" <>
          "DD9D202C3AB45713" <>
          "00" <>
          "55810100"
      )

    assert %Bitcoin.Protocol.Messages.Version{
             address_of_receiving_node: %Bitcoin.Protocol.Types.NetworkAddress{
               services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
               address: {10, 0, 0, 1},
               port: 8333
             },
             address_of_sending_node: %Bitcoin.Protocol.Types.NetworkAddress{
               services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
               address: {10, 0, 0, 2},
               port: 8333
             },
             nonce: 1_393_780_771_635_895_773,
             relay: false,
             services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
             start_height: 98645,
             timestamp: 1_292_899_814,
             user_agent: "",
             version: 31900
           } ==
             Version.parse(payload)
  end

  test "parses the version payload for protocol version 60002" do
    # 60002 (protocol version 60002)
    payload =
      Base.decode16!(
        # 1 (NODE_NETWORK services)
        # Tue Dec 18 10:12:33 PST 2012
        # Recipient address info - see Network Address
        # Sender address info - see Network Address
        # Node random unique ID
        # "/Satoshi:0.7.2/" sub-version string (string is 15 bytes long)
        # Last block sending node has is block #212672
        # Enable Relay Fl
        "62EA0000" <>
          "0100000000000000" <>
          "11B2D05000000000" <>
          "010000000000000000000000000000000000FFFF000000000000" <>
          "010000000000000000000000000000000000FFFF000000000000" <>
          "3B2EB35D8CE61765" <>
          "0F2F5361746F7368693A302E372E322F" <>
          "C03E0300" <>
          "01"
      )

    assert %Bitcoin.Protocol.Messages.Version{
             address_of_receiving_node: %Bitcoin.Protocol.Types.NetworkAddress{
               services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
               address: {0, 0, 0, 0},
               port: 0
             },
             address_of_sending_node: %Bitcoin.Protocol.Types.NetworkAddress{
               services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
               address: {0, 0, 0, 0},
               port: 0
             },
             nonce: 7_284_544_412_836_900_411,
             relay: true,
             services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
             start_height: 212_672,
             timestamp: 1_355_854_353,
             user_agent: "/Satoshi:0.7.2/",
             version: 60002
           } ==
             Version.parse(payload)
  end

  test "version payload for protocol version 70002" do
    # Hexdump source: https://bitcoin.org/en/developer-reference#version
    # Protocol version: 70002
    payload =
      Base.decode16!(
        # Services: NODE_NETWORK
        # Epoch time: 1415483324
        # Receiving node's services
        #  Receiving node's IPv6 address
        # Receiving node's port number
        # Transmitting node's services
        # Transmitting node's IPv6 address
        # Transmitting node's port number
        # Nonce
        # Bytes in user agent string: 15
        # User agent: /Satoshi:0.9.2.1/
        # Start height: 329167
        # Relay flag: true
        "72110100" <>
          "0100000000000000" <>
          "BC8F5E5400000000" <>
          "0100000000000000" <>
          "00000000000000000000FFFFC61B6409" <>
          "208D" <>
          "0100000000000000" <>
          "00000000000000000000FFFFCB0071C0" <>
          "208D" <>
          "128035CBC97953F8" <>
          "0F" <>
          "2F5361746F7368693A302E392E332F" <>
          "CF050500" <>
          "01"
      )

    parsed_msg = %Bitcoin.Protocol.Messages.Version{
      address_of_receiving_node: %Bitcoin.Protocol.Types.NetworkAddress{
        address: {198, 27, 100, 9},
        port: 8333,
        services: <<1, 0, 0, 0, 0, 0, 0, 0>>
      },
      address_of_sending_node: %Bitcoin.Protocol.Types.NetworkAddress{
        address: {203, 0, 113, 192},
        port: 8333,
        services: <<1, 0, 0, 0, 0, 0, 0, 0>>
      },
      nonce: 17_893_779_652_077_781_010,
      relay: true,
      services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
      start_height: 329_167,
      timestamp: 1_415_483_324,
      user_agent: "/Satoshi:0.9.3/",
      version: 70002
    }

    # Test parsing
    assert Version.parse(payload) == parsed_msg

    # Test serialization
    assert Version.serialize(parsed_msg) == payload

    # Test parsing full message with header
    # bitcoin main net identifier, magic value 0xD9B4BEF9
    # 'version' command
    # payload length, in this case, one byte
    # invalid checksum, update wehn implementde
    header =
      <<0xF9, 0xBE, 0xB4, 0xD9>> <>
        "version" <>
        <<0, 0, 0, 0, 0>> <>
        <<byte_size(payload)::unsigned-little-integer-size(32)>> <>
        <<0, 0, 0, 0>>

    assert Bitcoin.Protocol.Message.parse(header <> payload).payload.message == parsed_msg
  end
end
