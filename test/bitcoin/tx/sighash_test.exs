defmodule Bitocin.Tx.SighashTest do
  use ExUnit.Case
  use Bitwise

  alias Bitcoin.Tx.Sighash

  test "defined_type?" do
    valid = [0x01, 0x02, 0x03, 0x80, 0x01 ^^^ 0x80, 0x02 ^^^ 0x80, 0x03 ^^^ 0x80]
    invalid = [0x04, 0x04 ^^^ 0x80, 0xFF, 0x00, 0x32]

    valid
    |> Enum.each(fn byte ->
      assert true == Sighash.valid_type?(byte), "#{byte} should be valid"
    end)
  end

  test "should be able to compute sighash for a coinbase tx" do
    tx_hex =
      "02000000010000000000000000000000000000000000000000000000000000000000000000ffffffff2e039b1e1304c0737c5b68747470733a2f2f6769746875622e636f6d2f62636578742f01000001c096020000000000ffffffff014a355009000000001976a91448b20e254c0677e760bab964aec16818d6b7134a88ac00000000"

    tx =
      tx_hex
      |> String.upcase()
      |> Base.decode16!()
      |> Bitcoin.Protocol.Messages.Tx.parse()

    sighash = Bitcoin.Tx.sighash(tx, 0, <<>>, 0x01) |> Bitcoin.Util.hash_to_hex()

    assert sighash == "6829f7d44dfd4654749b8027f44c9381527199f78ae9b0d58ffc03fdab3c82f1"
  end

  # File.read!("test/data/sighash_forkid.json") 
  # |> Poison.decode! 
  # # remove comments
  # |> Enum.filter(fn c -> length(c) > 1 end)
  # |> Enum.with_index
  # |> Enum.map(fn {[tx_hex, sub_script_hex, input_index, sighash_type, result], idx} ->
  #   tx =
  #     tx_hex
  #     |> String.upcase
  #     |> Base.decode16!
  #     |> Bitcoin.Protocol.Messages.Tx.parse

  #   sub_script = sub_script_hex |> String.upcase |> Base.decode16!

  #   sighash = Bitcoin.Tx.sighash(tx, input_index, sub_script, sighash_type) |> Bitcoin.Util.hash_to_hex
  #   @sighash sighash
  #   @result result

  #   test "sighash core test ##{idx}" do
  #     assert @sighash == @result
  #   end
  # end)
end
