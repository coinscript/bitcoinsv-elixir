defmodule Bitcoin.ChainParams.Testnet do
  @moduledoc """
    List of constants associated with the Bitcoin testnet (v3).

    https://github.com/bitcoin/bitcoin/blob/master/src/chainparams.cpp
  """

  defmacro __using__(_opts) do
    quote do
      @genesis_block "0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4adae5494dffff001d1aa4ae180101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000"
                     |> Binary.from_hex()
                     |> Bitcoin.Protocol.Messages.Block.parse()

      @genesis_hash "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943"
                    |> Bitcoin.Util.hex_to_hash()

      @network_magic_bytes <<0xF4, 0xE5, 0xF3, 0xF4>>

      @default_listen_port 18333

      @default_rpc_port 18332

      # bytes to append before base56check encoding
      @address_prefix [
        public: 111,
        script: 196,
        private: 239
      ]

      @dns_seeds [
        # Bitcoin SV seeder
        {"bitcoinsv.io", 'testnet-seed.bitcoinsv.io'},
        # Bitprim
        {"bitprim.org", 'testnet-seed.bitprim.org'},
        # Amaury SÉCHET
        {"deadalnix.me", 'testnet-seed.deadalnix.me'},
        # criptolayer.net
        {"criptolayer.net", 'testnet-seeder.criptolayer.net'}
      ]

      # BIPs activation conditions

      # P2SH
      @bip16_switch_time 1_333_238_400

      # Strict DER
      @bip66_height 330_776
    end
  end
end
