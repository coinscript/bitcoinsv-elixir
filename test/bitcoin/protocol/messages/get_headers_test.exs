defmodule Bitcoin.Protocol.Messages.GetHeadersTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Messages.GetHeaders

  test "parses the get headers message with 1 locator hash" do
    # 31900 (version 0.3.19)
    payload =
      Base.decode16!(
        # number of locator hashes, one
        # stop hash
        "9C7C0000" <>
          "01" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B835"
      )

    struct = %GetHeaders{
      block_locator_hashes: [
        Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855")
      ],
      hash_stop:
        Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B835"),
      version: 31900
    }

    assert GetHeaders.parse(payload) == struct
    assert GetHeaders.serialize(struct) == payload
  end

  test "parses the get headers message with 2 locator hashes" do
    # 31900 (version 0.3.19)
    payload =
      Base.decode16!(
        # number of locator hashes, one
        # stop hash
        "9C7C0000" <>
          "02" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B815" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855" <>
          "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B835"
      )

    struct = %GetHeaders{
      block_locator_hashes: [
        Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B815"),
        Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855")
      ],
      hash_stop:
        Base.decode16!("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B835"),
      version: 31900
    }

    assert GetHeaders.parse(payload) == struct
    assert GetHeaders.serialize(struct) == payload
  end
end
