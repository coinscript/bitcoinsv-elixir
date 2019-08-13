defmodule BitcoinTest.Protocol.Types.InventoryVectorTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Types.InventoryVector

  test "reference type error" do
    # type: 00 - Error
    payload =
      Base.decode16!(
        # hash
        "00000000" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
      )

    struct = %InventoryVector{
      hash: Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"),
      reference_type: :error
    }

    assert InventoryVector.parse(payload) == struct
    assert InventoryVector.serialize(struct) == payload
  end

  test "reference type msg_tx" do
    # type: 01 - MsgTX
    payload =
      Base.decode16!(
        # hash
        "01000000" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
      )

    struct = %InventoryVector{
      hash: Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"),
      reference_type: :msg_tx
    }

    assert InventoryVector.parse(payload) == struct
    assert InventoryVector.serialize(struct) == payload
  end

  test "reference type msg_block" do
    # type: 01 - MsgBlock
    payload =
      Base.decode16!(
        # hash
        "02000000" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
      )

    struct = %InventoryVector{
      hash: Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"),
      reference_type: :msg_block
    }

    assert InventoryVector.parse(payload) == struct
    assert InventoryVector.serialize(struct) == payload
  end

  test "reference type msg_filtered_block" do
    # type: 01 - MsgFilteredBlock
    payload =
      Base.decode16!(
        # hash
        "03000000" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
      )

    struct = %InventoryVector{
      hash: Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"),
      reference_type: :msg_filtered_block
    }

    assert InventoryVector.parse(payload) == struct
    assert InventoryVector.serialize(struct) == payload
  end
end
