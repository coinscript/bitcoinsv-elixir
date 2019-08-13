defmodule BitcoinTest.Protocol.Types.NetworkAddressTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Types.NetworkAddress

  test "IPv4 Addresses w/o Time (for Version Message)" do
    # - 1 (NODE_NETWORK service - see version message)
    binary =
      Base.decode16!(
        # - IPv4: 10.0.0.1, IPv6: ::ffff:10.0.0.1 (IPv4-mapped IPv6 address)
        # - port 8333"
        "0100000000000000" <>
          "00000000000000000000FFFF0A000001" <>
          "208D"
      )

    struct = %Bitcoin.Protocol.Types.NetworkAddress{
      address: {10, 0, 0, 1},
      port: 8333,
      services: <<1, 0, 0, 0, 0, 0, 0, 0>>
    }

    assert NetworkAddress.parse_version(binary) == struct
    assert NetworkAddress.serialize_version(struct) == binary
  end

  test "IPv4 Addresses w/ Time" do
    # - Mon Dec 20 21:50:10 EST 2010 (only when version is >= 31402)
    binary =
      Base.decode16!(
        # - 1 (NODE_NETWORK service - see version message)
        # - IPv4: 10.0.0.1, IPv6: ::ffff:10.0.0.1 (IPv4-mapped IPv6 address)
        # - port 8333"
        "E215104D" <>
          "0100000000000000" <>
          "00000000000000000000FFFF0A000001" <>
          "208D"
      )

    struct = %Bitcoin.Protocol.Types.NetworkAddress{
      time: 1_292_899_810,
      address: {10, 0, 0, 1},
      port: 8333,
      services: <<1, 0, 0, 0, 0, 0, 0, 0>>
    }

    assert NetworkAddress.parse(binary) == struct
    assert NetworkAddress.serialize(struct) == binary
  end
end
