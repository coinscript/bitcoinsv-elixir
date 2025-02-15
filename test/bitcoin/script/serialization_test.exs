defmodule Bitcoin.Script.SerializationTest do
  use ExUnit.Case

  @parsed_scripts %{
    "76A914C398EFA9C392BA6013C5E04EE729755EF7F58B3288AC" => [
      :OP_DUP,
      :OP_HASH160,
      <<195, 152, 239, 169, 195, 146, 186, 96, 19, 197, 224, 78, 231, 41, 117, 94, 247, 245, 139,
        50>>,
      :OP_EQUALVERIFY,
      :OP_CHECKSIG
    ],

    # Some examples taken from bitcoin-ruby tests (https://github.com/lian/bitcoin-ruby/blob/master/spec/bitcoin/script/script_spec.rb)
    "526B006B7DAC7CA9143CD1DEF404E12A85EAD2B4D3F5F9F817FB0D46EF879A6C93" => [
      :OP_2,
      :OP_TOALTSTACK,
      :OP_FALSE,
      :OP_TOALTSTACK,
      :OP_TUCK,
      :OP_CHECKSIG,
      :OP_SWAP,
      :OP_HASH160,
      <<60, 209, 222, 244, 4, 225, 42, 133, 234, 210, 180, 211, 245, 249, 248, 23, 251, 13, 70,
        239>>,
      :OP_EQUAL,
      :OP_BOOLAND,
      :OP_FROMALTSTACK,
      :OP_ADD
    ],
    "0002FFFFAB5102FFFF51AE" => [
      :OP_FALSE,
      <<255, 255>>,
      :OP_CODESEPARATOR,
      :OP_TRUE,
      <<255, 255>>,
      :OP_TRUE,
      :OP_CHECKMULTISIG
    ],
    "6A04DEADBEEF" => [:OP_RETURN, <<222, 173, 190, 239>>]
  }

  test "parse" do
    @parsed_scripts
    |> Enum.each(fn {hex, script} ->
      assert Bitcoin.Script.parse(hex |> Base.decode16!()) == script
    end)
  end

  test "parse string" do
    [
      {
        "005163A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A7681468CA4FEC736264C13B859BAC43D5173DF687168287",
        # I admit, a bit of an overkill ;) that's what I had at hand
        "0 1 OP_IF OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ELSE OP_ELSE OP_SHA1 OP_ENDIF 68ca4fec736264c13b859bac43d5173df6871682 OP_EQUAL"
      },
      {"6362675168", "OP_IF OP_VER OP_ELSE 1 OP_ENDIF"},
      # :invalid
      {"6365675168", "OP_IF OP_VERIF OP_ELSE 1 OP_ENDIF"}
    ]
    |> Enum.map(fn {hex, string} ->
      assert Bitcoin.Script.parse(hex |> Base.decode16!()) == Bitcoin.Script.parse_string(string)

      assert Bitcoin.Script.parse(hex |> Base.decode16!())
             |> Bitcoin.Script.Serialization.to_string() == string
    end)
  end

  test "parse string2" do
    [
      {"-549755813887 SIZE 5 EQUAL", [<<255, 255, 255, 255, 255>>, :OP_SIZE, :OP_5, :OP_EQUAL]},
      {"", []},
      {" EQUAL", [:OP_EQUAL]},
      {" 2    EQUAL     ", [:OP_2, :OP_EQUAL]},
      {"'Az'", ["Az"]}
    ]
    |> Enum.map(fn {string, script} ->
      assert Bitcoin.Script.parse_string2(string) == script
    end)
  end

  test "to binary" do
    [
      "005163A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A76767A7681468CA4FEC736264C13B859BAC43D5173DF687168287",
      "6362675168",
      "0100917551",
      "00483045022015BD0139BCCCF990A6AF6EC5C1C52ED8222E03A0D51C334DF139968525D2FCD20221009F9EFE325476EB64C3958E4713E9EEFE49BF1D820ED58D2112721B134E2A1A5303483045022015BD0139BCCCF990A6AF6EC5C1C52ED8222E03A0D51C334DF139968525D2FCD20221009F9EFE325476EB64C3958E4713E9EEFE49BF1D820ED58D2112721B134E2A1A5303"
    ]
    |> Enum.map(fn hex ->
      bin = hex |> Base.decode16!()
      script = bin |> Bitcoin.Script.parse()
      assert bin == Bitcoin.Script.to_binary(script)
    end)
  end
end
