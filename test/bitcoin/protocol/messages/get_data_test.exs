defmodule Bitcoin.Protocol.Messages.GetDataTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Messages.GetData
  alias Bitcoin.Protocol.Types.InventoryVector

  test "getdata message with 2 inventory vectors" do
    # 2 vectors in this message
    payload =
      Base.decode16!(
        # Inventory Vector 1
        # type: 03 - MsgFilteredBlock
        # hash
        # Inventory Vector 2
        # type: 01 - MsgTx
        # hash
        "02" <>
          "03000000" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855" <>
          "01000000" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
      )

    struct = %GetData{
      inventory_vectors: [
        %InventoryVector{
          reference_type: :msg_filtered_block,
          hash: Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855")
        },
        %InventoryVector{
          reference_type: :msg_tx,
          hash: Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855")
        }
      ]
    }

    assert GetData.parse(payload) == struct
    assert GetData.serialize(struct) == payload
  end
end
