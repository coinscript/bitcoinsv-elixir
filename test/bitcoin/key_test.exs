defmodule Bitcoin.KeyTest do
  use ExUnit.Case
  alias Bitcoin.Key
  alias Bitcoin.Crypto

  test "privkey to pubkey" do
    privkey =
      "c28a9f80738f770d527803a566cf6fc3edf6cea586c4fc4a5223a5ad797e1ac3" |> Binary.from_hex()

    pubkey =
      "033d5c2875c9bd116875a71a5db64cffcb13396b163d039b1d9327824891804334" |> Binary.from_hex()

    pubkey1 = Key.privkey_to_pubkey(privkey)
    assert pubkey1 == pubkey

    privkey2 =
      "1AEB4829D9E92290EF35A3812B363B0CA87DFDA2B628060648339E9452BC923A" |> Binary.from_hex()

    address2 = "1EMHJsiXjZmffBUWevGS5mWdoacmpt8vdH"
    pubkey2 = Key.privkey_to_pubkey(privkey2)
    assert address2 == Bitcoin.Key.Public.to_address(pubkey2)
  end

  test "privkey to wif" do
    p = "1AEB4829D9E92290EF35A3812B363B0CA87DFDA2B628060648339E9452BC923A" |> Binary.from_hex()
    wif = Key.privkey_to_wif(p)

    assert "Kx83ACqTy1EVasPzY9nPecfhbRwnqS1Gpjw2nUqxkD6ATc8dBEeW" == wif
  end

  test "privkey_to_scriptcode" do
    p = "1AEB4829D9E92290EF35A3812B363B0CA87DFDA2B628060648339E9452BC923A" |> Binary.from_hex()

    scriptcode =
      <<118, 169, 20, 146, 111, 145, 91, 215, 40, 85, 134, 174, 121, 91, 164, 4, 97, 211, 212,
        174, 83, 118, 8, 136, 172>>

    pubkey =
      "024da90ca8bf7861e2bee6931de4588ebba3850a1ad3f05ccd45cad2dd17ba7ae7" |> Binary.from_hex()

    pubkeyhash = "926f915bd7285586ae795ba40461d3d4ae537608" |> Binary.from_hex()
    assert pubkeyhash == Crypto.ripemd160(Crypto.sha256(pubkey))

    assert scriptcode == Key.privkey_to_scriptcode(p)
  end
end
