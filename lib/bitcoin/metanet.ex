# defmodule Bitcoin.Metanet do
#   alias Bitcoin.Key

#   use GenServer

#   def new() do
#     root_private_key = Key.new_private_key()
#     load(Binary.to_hex(root_private_key))
#   end

#   def new(hex_private_key) do
#     {:ok, pid} = GenServer.start_link(__MODULE__, {:hex_private_key, hex_private_key})
#     pid
#   end

#   def init({:hex_private_key, hex_private_key}) do
#     bn_private_key = hex2bin(hex_private_key)
#     bn_public_key = Key.privkey_to_pubkey(bn_private_key)
#     address = Key.Public.to_address(bn_public_key)
#     int_private_key = :binary.decode_unsigned(bn_private_key)
#     state = %{
#       bn_private_key: bn_private_key,
#       hex_private_key: hex_private_key,
#       bn_public_key: bn_public_key,
#       address: address,
#       fund_private_key: bn_private_key, ## the key fund the tx fee

#     }
#   end
# end
