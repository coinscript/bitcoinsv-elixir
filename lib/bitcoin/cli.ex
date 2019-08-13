defmodule Bitcoin.Cli do
  alias Bitcoin.Tx.TxMaker
  alias Bitcoin.Key

  require Logger
  use GenServer

  def new_wallet() do
    private_key = Key.new_private_key()
    new_wallet(bin2hex(private_key))
  end

  # hex_string -> wallet
  def new_wallet(hex_private_key) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {:hex_private_key, hex_private_key})
    pid
  end

  def init({:hex_private_key, hex_private_key}) do
    bn_private_key = hex2bin(hex_private_key)
    bn_public_key = Key.privkey_to_pubkey(bn_private_key)
    address = Key.Public.to_address(bn_public_key)

    state = %{
      hex_private_key: hex_private_key,
      bn_private_key: bn_private_key,
      bn_public_key: bn_public_key,
      address: address,
      balance: nil,
      utxos: [],
      utxo_count: 0
    }

    Logger.debug(inspect(state))
    {:ok, state}
  end

  # wallet -> integer
  def get_balance(wallet) do
    GenServer.call(wallet, :get_balance)
  end

  # wallet, [{address, satoshis}] -> rpc_txid
  def transfer(wallet, outputs, fee_per_byte \\ 1) do
    Logger.debug(inspect(outputs))
    GenServer.call(wallet, {:transfer, outputs, fee_per_byte}, :infinity)
  end

  def handle_call(:get_balance, _, state) do
    utxos = TxMaker.Resource.utxos(state.address)
    sum_of_utxos = get_sum_of_utxos(utxos)

    state = %{
      state
      | balance: sum_of_utxos,
        utxos: utxos,
        utxo_count: length(utxos)
    }

    {:reply, state.balance, state}
  end

  def handle_call({:transfer, outputs, fee_per_byte}, _, state) do
    sum_of_outputs =
      Enum.reduce(outputs, 0, fn
        {_, value}, acc -> acc + value
        _, acc -> acc
      end)

    if sum_of_outputs >= state.balance do
      raise("insufficient balance")
    end

    output_count = length(outputs)

    {spendings, outputs} =
      case get_enough_utxos(
             state.utxos,
             sum_of_outputs,
             output_count,
             [],
             0,
             fee_per_byte,
             get_opreturn_size(outputs)
           ) do
        {:no_change, spendings} ->
          {spendings, outputs}

        {:change, change, spendings} ->
          outputs = outputs ++ [{state.address, change}]
          {spendings, outputs}
      end

    hex_tx = TxMaker.create_p2pkh_transaction(state.bn_private_key, spendings, outputs)

    rpc_txid = TxMaker.broadcast(hex_tx)

    {:reply, rpc_txid, state}
  end

  defp get_sum_of_utxos(utxos) do
    Enum.reduce(utxos, 0, fn x, acc -> acc + x.amount end)
  end

  defp get_opreturn_size(outputs) do
    outputs
    |> Enum.reduce(0, fn x, acc ->
      size =
        case x do
          %{type: "safe", data: data} ->
            data = if is_list(data), do: Enum.join(data), else: data
            byte_size(data)

          {_, _} ->
            0
        end

      acc + size
    end)
  end

  defp get_enough_utxos(
         utxos,
         sum_of_outputs,
         output_count,
         spendings,
         spending_count,
         fee_per_byte,
         opreturn_size
       ) do
    fee_with_change = get_fee(spending_count, output_count + 1, fee_per_byte, opreturn_size)
    # fee_without_change = get_fee(spending_count, output_count)
    sum_of_spendings = get_sum_of_utxos(spendings)

    cond do
      # # no need change, change value less than dust limit
      # sum_of_spendings >= fee_without_change + sum_of_outputs and sum_of_spendings - (fee_without_change + sum_of_outputs) <= 546 ->
      #   {:no_change, spendings}

      sum_of_spendings <= fee_with_change + sum_of_outputs and utxos == [] ->
        {:error, "insufficient balance"}

      sum_of_spendings <= fee_with_change + sum_of_outputs ->
        get_enough_utxos(
          tl(utxos),
          sum_of_outputs,
          output_count,
          [hd(utxos) | spendings],
          spending_count + 1,
          fee_per_byte,
          opreturn_size
        )

      true ->
        change = sum_of_spendings - (fee_with_change + sum_of_outputs)

        if change >= 546 do
          {:change, change, spendings}
        else
          {:no_change, spendings}
        end
    end
  end

  defp hex2bin(x), do: Binary.from_hex(x)
  defp bin2hex(x), do: Binary.to_hex(x)

  defp get_fee(n_in, n_out, fee_per_byte, opreturn_size) do
    TxMaker.estimate_tx_fee(n_in, n_out, fee_per_byte, true, opreturn_size)
  end

  def test do
    w = new_wallet("8b559565ec6754895b6f378fa935740e34bb7d9b515ade65c6dc06081e3b63c7")
    # get_balance w
    # outputs = [%{type: "safe", data: "我真牛🍺 "}]
    # transfer w, outputs
  end
end
