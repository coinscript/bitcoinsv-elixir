defmodule Bitcoin.Tx.TxMaker do
  alias Bitcoin.Base58Check
  alias Bitcoin.Protocol.Types.VarInteger
  alias Bitcoin.Key
  alias Bitcoin.Crypto
  require Logger

  defmodule Resource do
    def utxos(addr) do
      {:ok, data} = SvApi.Bitindex.utxos(addr)
      utxos = for d <- data do
        %{
          txid: d["txid"],
          txindex: d["vout"],
          amount: d["value"],
          script: d["scriptPubKey"]
        }
      end
      utxos
    end

    # def balance(_addr) do
    #   # TODO
    #   0
    # end
  end

  def broadcast(hex) do
    SvApi.Bitindex.broadcast(hex)
  end

  def address_to_public_key_hash(addr) do
    {:ok, <<_prefix::bytes-size(1), pubkeyhash::binary>>} = Base58Check.decode(addr)
    pubkeyhash
  end

  def len(x) when is_binary(x), do: byte_size(x)
  def len(x) when is_list(x), do: length(x)

  def to_bytes(x, size, endian \\ :big) when is_integer(x) do
    s = 8*size
    case endian do
      :big ->
        <<x::size(s)-big>>
      :little ->
        <<x::size(s)-little>>
    end
  end

  def scriptcode(private_key) do
    pkhash = Key.privkey_to_pubkey_hash(private_key)
    [
      0x76, 0xa9, 0x14, pkhash, 0x88, 0xac
    ] |> join()
  end

  def int_to_varint(x) do
    VarInteger.serialize(x)
  end

  def hex_to_bytes(hex) do
    Binary.from_hex(hex)
  end

  def bytes_to_hex(b), do: Binary.to_hex(b)

  def double_sha256(x) do
    x |> sha256() |> sha256()
  end

  def sha256(x), do: :crypto.hash(:sha256, x)

  def join(list), do: IO.iodata_to_binary(list)

  def construct_input_block(inputs) do
    for txin <- inputs do
      join([
        txin.txid,
        txin.txindex,
        txin.script_len,
        txin.script,
        sequence()
      ])
    end |> join()
  end

  def construct_output_block(outputs) do
    Enum.map(outputs, fn output ->
      script = case output do
        {dest, amount} ->
          [
            0x76, 0xa9, 0x14, address_to_public_key_hash(dest), 0x88, 0xac
          ] |> join()
        ## what is "safe" type: https://blog.moneybutton.com/2019/08/02/money-button-now-supports-safe-on-chain-data/
        %{type: "safe", data: data} ->
          data = if is_list(data), do: data, else: [data]
          [
            0, 106, (for x <- data, do: [byte_size(x), x])
          ] |> join()
      end
      amount = case output do
        {_dest, amount} -> amount
        %{type: "safe"} -> 0
      end
      [
        amount |> to_bytes(8, :little),
        int_to_varint(len(script)),
        script
      ]
    end) |> join()
  end

  def newTxIn(script, script_len, txid, txindex, amount) do
    %{
      script: script,
      script_len: script_len,
      txid: txid,
      txindex: txindex,
      amount: amount
    }
  end

  def sequence(), do: 0xffffffff |> to_bytes(4, :little)

  def create_p2pkh_transaction(private_key, unspents, outputs) do
    public_key = Key.privkey_to_pubkey(private_key)
    public_key_len = len(public_key) |> to_bytes(1, :little)

    scriptCode = scriptcode(private_key)
    scriptCode_len = int_to_varint(len(scriptCode))

    version = 0x01 |> to_bytes(4, :little)
    sequence = sequence()
    lock_time = 0x00 |> to_bytes(4, :little)
    hash_type = 0x41 |> to_bytes(4, :little)

    input_count = int_to_varint(len(unspents))
    output_count = int_to_varint(len(outputs))

    output_block = construct_output_block(outputs)

    inputs =
      for unspent <- unspents do
        script = hex_to_bytes(unspent.script)
        script_len = int_to_varint(len(script))
        txid = hex_to_bytes(unspent.txid) |> Binary.reverse()
        txindex = unspent.txindex |> to_bytes(4, :little)
        amount = unspent.amount |> to_bytes(8, :little)

        newTxIn(script, script_len, txid, txindex, amount)
      end

    hashPrevouts = double_sha256(join(for i <- inputs, do: [i.txid, i.txindex]))
    hashSequence = double_sha256(join(for _i <- inputs, do: sequence))
    hashOutputs = double_sha256(output_block)

    inputs =
      for txin <- inputs do
        to_be_hashed = join([
          version,
          hashPrevouts,
          hashSequence,
          txin.txid,
          txin.txindex,
          scriptCode_len,
          scriptCode,
          txin.amount,
          sequence,
          hashOutputs,
          lock_time,
          hash_type
        ])

        hashed = sha256(to_be_hashed)

        signature = Crypto.sign(private_key, hashed) <> <<0x41>>

        script_sig = join([
          len(signature) |> to_bytes(1, :little),
          signature,
          public_key_len,
          public_key
        ])

        %{
          txin |
          script: script_sig,
          script_len: int_to_varint(len(script_sig))
        }
      end

    bytes_to_hex(join([
      version,
      input_count,
      construct_input_block(inputs),
      output_count,
      output_block,
      lock_time
    ]))
  end


  def estimate_tx_fee(n_in, n_out, satoshis, compressed, op_return_size \\ 0) do

    # 费率未知, 返回 0
    if !satoshis do
      0
    else

      # 估算交易体积
      estimated_size = (
          # version
          4 +
          n_in * (if compressed, do: 148, else: 180) +
          # input count 的长度
          len(int_to_varint(n_in)) +
          # excluding op_return outputs, dealt with separately
          n_out * 34 +
          # output count 的长度
          len(int_to_varint(n_out)) +
          # grand total size of op_return outputs(s) and related field(s)
          op_return_size +
          # time lock
          4
      )

      estimated_fee = estimated_size * satoshis # 体积乘以费率得到估计的手续费

      Logger.debug("Estimated fee: #{estimated_fee} satoshis for #{estimated_size} bytes")

      estimated_fee
    end
  end

  @doc """
  This function just for testing.
  send all balance back to sender, just minus fee.
  """
  def quick_send() do
    priv = "1AEB4829D9E92290EF35A3812B363B0CA87DFDA2B628060648339E9452BC923A" |> Binary.from_hex()
    addr = "1EMHJsiXjZmffBUWevGS5mWdoacmpt8vdH"
    utxos = [Resource.utxos(addr) |> IO.inspect() |> Enum.max_by(fn x -> x.amount end)]
    outputs = [
      {addr, hd(utxos).amount - 230}
    ]
    create_p2pkh_transaction(priv, utxos, outputs)
    |> broadcast()
  end




end
