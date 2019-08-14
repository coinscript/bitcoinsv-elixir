defmodule Bitcoin.Key do
  alias Bitcoin.Base58Check
  alias Bitcoin.Script
  alias Bitcoin.Crypto

  def new_private_key() do
    {_, priv} = :crypto.generate_key(:ecdh, :secp256k1)
    priv
  end

  def privkey_to_pubkey(priv) do
    {publickey, _priv} = :crypto.generate_key(:ecdh, :secp256k1, priv)
    compress(publickey)
  end

  def privkey_to_pubkey_hash(priv) do
    priv
    |> privkey_to_pubkey()
    |> Crypto.sha256()
    |> Crypto.ripemd160()
  end

  def compress(<<_prefix::size(8), x_coordinate::size(256), y_coordinate::size(256)>>) do
    prefix =
      case rem(y_coordinate, 2) do
        0 -> 0x02
        _ -> 0x03
      end

    <<prefix::size(8), x_coordinate::size(256)>>
  end

  def privkey_to_wif(priv) do
    # mainnet
    prefix = <<0x80>>

    suffix =
      if compressed_priv?(priv) do
        <<0x01>>
      else
        ""
      end

    (prefix <> priv <> suffix)
    |> Base58Check.encode()
  end

  def compressed_priv?(priv) do
    pub = priv |> privkey_to_pubkey()
    byte_size(pub) == 33
  end

  def privkey_to_scriptcode(priv) do
    [:OP_DUP, :OP_HASH160, privkey_to_pubkey_hash(priv), :OP_EQUALVERIFY, :OP_CHECKSIG]
    |> Script.to_binary()
  end

  def address_to_pkscript(addr) do
    [:OP_DUP, :OP_HASH160, Bitcoin.Tx.TxMaker.address_to_public_key_hash(addr), :OP_EQUALVERIFY, :OP_CHECKSIG] |> Script.to_binary()
  end
end
