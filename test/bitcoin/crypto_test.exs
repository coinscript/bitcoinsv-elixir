defmodule Bitcoin.CryptoTest do
  use ExUnit.Case

  alias Bitcoin.Crypto
  alias Bitcoin.Util
  alias Bitcoin.Key

  @priv "1AEB4829D9E92290EF35A3812B363B0CA87DFDA2B628060648339E9452BC923A" |> Binary.from_hex()

  test "secp256k1 testcases" do
    priv = "31a84594060e103f5a63eb742bd46cf5f5900d8406e2726dedfc61c7cf43ebad" |> Binary.from_hex()
    pubkey = Key.privkey_to_pubkey(priv)

    message =
      "9e5755ec2f328cc8635a55415d0e9a09c2b6f2c9b0343c945fbbfe08247a4cbe" |> Binary.from_hex()

    assert true == Crypto.verify(Crypto.sign(priv, message), message, pubkey)
  end

  test "double sha256" do
    assert Crypto.double_sha256("") ==
             "5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456"
             |> Binary.from_hex()
  end
end
