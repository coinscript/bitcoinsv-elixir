defmodule Bitcoin.ChainParams.Bitcoin do
  @moduledoc """
    List of constants associated with the Bitcoin mainnet.

    https://github.com/bitcoin/bitcoin/blob/master/src/chainparams.cpp
  """

  defmacro __using__(_opts) do
    quote do
      @genesis_block "0100000000000000000000000000000000000000000000000000000000000000000000003BA3EDFD7A7B12B27AC72C3E67768F617FC81BC3888A51323A9FB8AA4B1E5E4A29AB5F49FFFF001D1DAC2B7C0101000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
                     |> Binary.from_hex()
                     |> Bitcoin.Protocol.Messages.Block.parse()

      @genesis_hash "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
                    |> Bitcoin.Util.hex_to_hash()

      @network_magic_bytes <<0xE3, 0xE1, 0xF3, 0xE8>>

      @default_listen_port 8333

      @default_rpc_port 8332

      # bytes to append before base56check encoding
      @address_prefix [
        public: 0,
        script: 5,
        private: 128
      ]

      @dns_seeds [
        # Bitcoin SV seeder
        {"bitcoinsv.io", 'seed.bitcoinsv.io'},
        # BU backed seeder
        {"bitcoinunlimited.info", 'btccash-seeder.bitcoinunlimited.info'},
        # Bitprim
        {"bitprim.org", 'seed.bitprim.org'},
        # Amaury SÉCHET
        {"deadalnix.me", 'seed.deadalnix.me'},
        # criptolayer.net
        {"criptolayer.net", 'seeder.criptolayer.net'}
      ]

      # BIPs activation conditions

      # P2SH
      @bip16_switch_time 1_333_238_400

      # Strict DER
      @bip66_height 363_725
    end
  end
end
