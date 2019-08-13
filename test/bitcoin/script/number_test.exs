defmodule Bitcoin.Script.NumberTest do
  use ExUnit.Case

  alias Bitcoin.Script.Number

  @cases [
    {<<>>, 0},
    # check if we do minimal encoding
    # https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki#numbers
    {<<0xFF>>, -127},
    {<<0x82>>, -2},
    {<<0x11>>, 17},
    {<<0x7F>>, 127},
    {<<0xFF, 0xFF>>, -32767},
    {<<0x80, 0x80>>, -128},
    {<<0x80, 0x00>>, 128},
    {<<0xFF, 0x7F>>, 32767},
    {<<0xFF, 0xFF, 0xFF>>, -8_388_607},
    {<<0x00, 0x80, 0x80>>, -32768},
    {<<0x00, 0x80, 0x00>>, 32768},
    {<<0xFF, 0xFF, 0x7F>>, 8_388_607},
    {<<0xFF, 0xFF, 0xFF, 0xFF>>, -2_147_483_647},
    # no 8
    {<<0x00, 0x00, 0x80, 0x80>>, -8_388_608},
    {<<0x00, 0x00, 0x80, 0x00>>, 8_388_608},
    {<<0xFF, 0xFF, 0xFF, 0x7F>>, 2_147_483_647}
  ]

  @cases
  |> Enum.each(fn {bin, num} ->
    @bin bin
    @num num

    test "decoding #{bin |> inspect}" do
      assert Number.num(@bin) == @num
    end

    test "encoding #{num |> inspect}" do
      assert Number.bin(@num) == @bin
    end
  end)

  # regtest, this failed with prev implementation
  test "encoding 4294967294" do
    assert Number.bin(4_294_967_294) == <<254, 255, 255, 255, 0>>
  end

  test "invalid ints" do
    # can be serialized, can't be interpreted as ints
    [4_294_967_294, -2_147_483_648]
    |> Enum.each(fn int ->
      assert_raise FunctionClauseError, fn ->
        int |> Number.bin() |> Number.num()
      end
    end)
  end
end
