defmodule Bitocin.Tx.TxMakerTest do
  alias Bitcoin.Tx.TxMaker
  alias Bitcoin.Protocol.Messages
  alias Bitcoin.Protocol.Types.TxInput
  alias Bitcoin.Protocol.Types.TxOutput
  alias Bitcoin.Protocol.Types.Outpoint
  alias Bitcoin.Tx.Utxo
  alias Bitcoin.Util

  use ExUnit.Case

  test "estimate_tx_fee" do
    assert 226 == TxMaker.estimate_tx_fee(1, 2, 1, true)
  end

  @final "01000000018878399d83ec25c627cfbf753ff9ca3602373eac437ab2676154a3c2da23adf3010000008a47304402204d6f28d77fa31cfc6c13bb1bda2628f2237e2630e892dc62bb319eb75dc7f9310220741f4df7d9460daa844389eb23fb318dd674967144eb89477608b10e03c175034141043d5c2875c9bd116875a71a5db64cffcb13396b163d039b1d932782489180433476a4352a2add00ebb0d5c94c515b72eb10f1fd8f3f03b42f4a2b255bfc9aa9e3ffffffff0250c30000000000001976a914e7c1345fc8f87c68170b3aa798a956c2fe6a9eff88ac0888fc04000000001976a91492461bde6283b461ece7ddf4dbf1e0a48bd113d888ac00000000"
         |> Binary.from_hex()

  @unspents [
    %Utxo{
      value: 83_727_960,
      script_pubkey: "76a91492461bde6283b461ece7ddf4dbf1e0a48bd113d888ac" |> Binary.from_hex(),
      hash:
        "f3ad23dac2a3546167b27a43ac3e370236caf93f75bfcf27c625ec839d397888"
        |> Bitcoin.Util.from_rpc_hex(),
      index: 1
    }
  ]

  @outputs [
    {"n2eMqTT929pb1RDNuqEnxdaLau1rxy3efi", 50000},
    {"mtrNwJxS1VyHYn3qBY1Qfsm3K3kh1mGRMS", 83_658_760}
  ]

  @utxos [
    %Bitcoin.Tx.Utxo{
      hash:
        <<224, 31, 249, 224, 107, 185, 250, 221, 188, 228, 110, 66, 46, 171, 93, 19, 196, 202,
          230, 99, 195, 212, 183, 209, 50, 108, 199, 37, 163, 18, 95, 200>>,
      index: 0,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 10000
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<41, 127, 249, 29, 153, 224, 170, 168, 113, 17, 140, 247, 91, 18, 245, 132, 254, 1, 156,
          119, 138, 39, 142, 19, 183, 221, 94, 99, 96, 106, 101, 98>>,
      index: 1,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 1000
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<219, 244, 133, 201, 221, 28, 225, 159, 123, 226, 114, 94, 228, 176, 84, 190, 253, 32,
          208, 201, 254, 180, 25, 246, 158, 49, 90, 91, 61, 117, 87, 56>>,
      index: 1,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 50208
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<235, 169, 251, 254, 55, 214, 109, 117, 97, 110, 188, 158, 34, 25, 222, 16, 218, 13, 127,
          157, 101, 153, 214, 35, 223, 66, 55, 57, 1, 5, 56, 83>>,
      index: 0,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 690_000
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<136, 145, 151, 199, 81, 57, 38, 171, 137, 212, 192, 60, 66, 149, 74, 154, 49, 8, 112,
          195, 87, 230, 14, 173, 84, 86, 192, 251, 159, 189, 41, 96>>,
      index: 1,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 11451
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<135, 68, 209, 180, 71, 47, 244, 23, 99, 200, 28, 57, 18, 152, 181, 10, 81, 168, 39, 241,
          82, 24, 66, 110, 180, 143, 92, 134, 23, 207, 173, 202>>,
      index: 0,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 821
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<172, 96, 8, 219, 134, 77, 23, 66, 117, 219, 1, 51, 69, 24, 38, 82, 94, 212, 192, 49, 86,
          217, 199, 69, 134, 80, 9, 242, 80, 109, 181, 160>>,
      index: 0,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 1000
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<152, 249, 171, 94, 172, 102, 110, 1, 100, 222, 43, 21, 114, 34, 96, 239, 199, 197, 60,
          215, 124, 159, 184, 4, 227, 159, 87, 101, 8, 0, 111, 6>>,
      index: 1,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 735_788
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<98, 128, 26, 251, 121, 223, 219, 216, 231, 148, 224, 103, 85, 49, 198, 54, 161, 233,
          218, 102, 34, 63, 174, 165, 63, 234, 137, 244, 83, 156, 64, 12>>,
      index: 0,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 100_000
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<98, 145, 116, 74, 218, 216, 132, 164, 240, 134, 146, 194, 252, 40, 13, 125, 177, 23,
          129, 16, 57, 7, 218, 191, 72, 81, 213, 137, 227, 225, 118, 13>>,
      index: 0,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 10000
    },
    %Bitcoin.Tx.Utxo{
      hash:
        <<240, 64, 129, 119, 236, 229, 40, 120, 209, 228, 86, 26, 235, 29, 112, 151, 160, 35, 84,
          184, 122, 200, 56, 2, 103, 236, 118, 154, 161, 35, 133, 103>>,
      index: 1,
      script_pubkey:
        <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
          235, 184, 143, 24, 136, 172>>,
      value: 10000
    }
  ]

  test "address_to_public_key_hash" do
    pubkeyhash = Binary.from_hex("3c3fa3d4adcaf8f52d5b1843975e122548269937")
    addr = "16VZnHwRhwrExfeHFHGjwrgEMq8VcYPs9r"

    assert pubkeyhash == TxMaker.address_to_public_key_hash(addr)
  end

  test "address_to_pk_script" do
    addr = "18WqBk5qDRXuwmphgg2oX5SpEWpV8uH1gk"
    pks = TxMaker.address_to_pk_script(addr)
    assert pks == Binary.from_hex("76a914526d2a97902d5dc95b6060a54dbcb74a587c818c88ac")
  end

  ## 优先选择数额大的 utxo, 这样总个数就会尽可能的少
  test "get_enough_utxos" do
    utxos = @utxos
    value = 98765

    spending = [
      %Bitcoin.Tx.Utxo{
        hash:
          <<152, 249, 171, 94, 172, 102, 110, 1, 100, 222, 43, 21, 114, 34, 96, 239, 199, 197, 60,
            215, 124, 159, 184, 4, 227, 159, 87, 101, 8, 0, 111, 6>>,
        index: 1,
        script_pubkey:
          <<118, 169, 20, 98, 233, 7, 177, 92, 191, 39, 213, 66, 83, 153, 235, 246, 240, 251, 80,
            235, 184, 143, 24, 136, 172>>,
        value: 735_788
      }
    ]

    assert spending == TxMaker.get_enough_utxos(utxos, value)

    value2 = 9_999_999_999

    assert_raise RuntimeError, "Balance not enough.", fn ->
      TxMaker.get_enough_utxos(utxos, value2)
    end
  end

  test "transaction test cases from python bsv lib" do
    final = @final

    inputs = [
      %TxInput{
        previous_output: %Outpoint{
          hash:
            <<136, 120, 57, 157, 131, 236, 37, 198, 39, 207, 191, 117, 63, 249, 202, 54, 2, 55,
              62, 172, 67, 122, 178, 103, 97, 84, 163, 194, 218, 35, 173, 243>>,
          index: 1
        },
        sequence: 0xFFFFFFFF,
        signature_script:
          "473044022045b743dbaaaa2cd1ef0b91346f5644e32dc70cde05091b3762d4cabb6ebd711a022074461056c26efeac0b448e7fa769773dd6e4436cde505c8f6ca6303efe31f0950141043d5c2875c9bd116875a71a5db64cffcb13396b163d039b1d932782489180433476a4352a2add00ebb0d5c94c515b72eb10f1fd8f3f03b42f4a2b255bfc9aa9e3"
          |> Binary.from_hex()
      }
    ]

    input_block =
      "8878399d83ec25c627cfbf753ff9ca3602373eac437ab2676154a3c2da23adf3010000008a473044022045b743dbaaaa2cd1ef0b91346f5644e32dc70cde05091b3762d4cabb6ebd711a022074461056c26efeac0b448e7fa769773dd6e4436cde505c8f6ca6303efe31f0950141043d5c2875c9bd116875a71a5db64cffcb13396b163d039b1d932782489180433476a4352a2add00ebb0d5c94c515b72eb10f1fd8f3f03b42f4a2b255bfc9aa9e3ffffffff"
      |> Binary.from_hex()

    unspents = @unspents

    outputs = @outputs |> Enum.map(&TxMaker.avp_to_output/1)

    messages = [
      {"hello", 0},
      {"there", 0}
    ]

    output_block =
      "50c30000000000001976a914e7c1345fc8f87c68170b3aa798a956c2fe6a9eff88ac0888fc04000000001976a91492461bde6283b461ece7ddf4dbf1e0a48bd113d888ac"

    {input, _} = TxInput.parse_stream(input_block)
    assert inputs == [input]

    outputs1 = Messages.Tx.parse(final).outputs
    assert outputs1 = outputs
  end

  # test "construct output block" do
  #   output_block = [
  #     %TxOutput{
  #       pk_script: <<118, 169, 20, 231, 193, 52, 95, 200, 248, 124, 104, 23, 11, 58,
  #         167, 152, 169, 86, 194, 254, 106, 158, 255, 136, 172>>,
  #       value: 50000
  #     },
  #     %TxOutput{
  #       pk_script: <<118, 169, 20, 146, 70, 27, 222, 98, 131, 180, 97, 236, 231,
  #         221, 244, 219, 241, 224, 164, 139, 209, 19, 216, 136, 172>>,
  #       value: 83658760
  #     }
  #   ]
  #   outputs = @outputs

  #   assert output_block == TxMaker.construct_output_block(outputs)
  # end

  # test "construct_input_block" do
  #   input_block = [
  #     %TxInput{
  #       previous_output: %Outpoint{
  #         hash: <<136, 120, 57, 157, 131, 236, 37, 198, 39, 207, 191,
  #           117, 63, 249, 202, 54, 2, 55, 62, 172, 67, 122, 178, 103,
  #           97, 84, 163, 194, 218, 35, 173, 243>>,
  #         index: 1
  #       },
  #       sequence: 4294967295,
  #       signature_script: ""
  #     }
  #   ]
  #   unspents = @unspents
  #   assert input_block == TxMaker.construct_input_block(unspents)
  # end

  # test "Test Create Signed Transaction" do
  #   outputs = [
  #     {"1PdvVPTzXmo4cSs68HctLUxAdW917UZtC8", 10000},
  #     {"1EMHJsiXjZmffBUWevGS5mWdoacmpt8vdH", 12578070}
  #   ]
  #   unspents = [
  #     %Utxo{
  #       value: 12588296,
  #       script_pubkey: "76a914926f915bd7285586ae795ba40461d3d4ae53760888ac" |> Binary.from_hex(),
  #       hash: "1f2de5350418ccca6234ccadf692035dbf057cf9d832d0e8f54fa2edbb6d00f6" |> Bitcoin.Util.from_rpc_hex(),
  #       index: 0
  #     }
  #   ]
  #   final = "0100000001f6006dbbeda24ff5e8d032d8f97c05bf5d0392f6adcc3462cacc180435e52d1f000000006a473044022064d13442cc47d55add49898a8c618a601dce110d67b56b6654fec1b0e95b2d13022015cba3c4b0f0fd36912192dd75ec72c9c5613c9bd00544b40f85ff78e8f436a24121024da90ca8bf7861e2bee6931de4588ebba3850a1ad3f05ccd45cad2dd17ba7ae7ffffffff0210270000000000001976a914f84e64817bcb214871a90d0dce34685377cbf48788ac16edbf00000000001976a914926f915bd7285586ae795ba40461d3d4ae53760888ac00000000"
  #   # "bitsv testcase: create signed transaction"

  #   privkey = "1AEB4829D9E92290EF35A3812B363B0CA87DFDA2B628060648339E9452BC923A" |> Binary.from_hex()

  #   tx = TxMaker.create_p2pkh_transaction(privkey, unspents, outputs)
  #   assert Util.print(final, "final") == Util.print(Messages.Tx.serialize(tx) |> Binary.to_hex(), "mytx")
  # end

  defp sig_script_from_inputs([h | _]) do
    h.signature_script
  end
end
