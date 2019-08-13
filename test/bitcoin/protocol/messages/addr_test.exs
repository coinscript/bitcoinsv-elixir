defmodule Bitcoin.Protocol.Messages.AddrTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Messages.Addr
  alias Bitcoin.Protocol.Types.NetworkAddress

  test "addr message with 1 address" do
    # 1 address in this message
    payload =
      Base.decode16!(
        # Mon Dec 20 21:50:10 EST 2010 (only when version is >= 31402)
        # 1 (NODE_NETWORK service - see version message)
        # IPv4: 10.0.0.1, IPv6: ::ffff:10.0.0.1 (IPv4-mapped IPv6 address)
        # port 8333
        "01" <>
          "E215104D" <>
          "0100000000000000" <>
          "00000000000000000000FFFF0A000001" <>
          "208D"
      )

    struct = %Addr{
      address_list: [
        %NetworkAddress{
          address: {10, 0, 0, 1},
          port: 8333,
          services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
          time: 1_292_899_810
        }
      ]
    }

    assert Addr.parse(payload) == struct
    assert Addr.serialize(struct) == payload
  end

  test "addr message with 2 addresses" do
    # 1 address in this message
    payload =
      Base.decode16!(
        # Address 1
        # Mon Dec 20 21:50:10 EST 2010 (only when version is >= 31402)
        # 1 (NODE_NETWORK service - see version message)
        # IPv4: 10.0.0.1, IPv6: ::ffff:10.0.0.1 (IPv4-mapped IPv6 address)
        # port 8333
        # Address 2
        # Mon Dec 20 21:50:10 EST 2010 (only when version is >= 31402)
        # 1 (NODE_NETWORK service - see version message)
        # IPv4: 10.0.0.2, IPv6: ::ffff:10.0.0.1 (IPv4-mapped IPv6 address)
        # port 8334
        "02" <>
          "E215104D" <>
          "0100000000000000" <>
          "00000000000000000000FFFF0A000001" <>
          "208D" <>
          "E215104D" <>
          "0100000000000000" <>
          "00000000000000000000FFFF0A000002" <>
          "208E"
      )

    struct = %Addr{
      address_list: [
        %NetworkAddress{
          address: {10, 0, 0, 1},
          port: 8333,
          services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
          time: 1_292_899_810
        },
        %NetworkAddress{
          address: {10, 0, 0, 2},
          port: 8334,
          services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
          time: 1_292_899_810
        }
      ]
    }

    assert Addr.parse(payload) == struct
    assert Addr.serialize(struct) == payload
  end
end
