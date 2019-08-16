defmodule Bitcoin.Metanet.B do
  @moduledoc """
  B:// protocol.
  """
  defstruct [
    inner: nil,
    # wallet for signing bcat parts
    wallet: nil
  ]

  alias Bitcoin.Cli
  alias Bitcoin.Metanet.Onchain

  @bcat "15DHFxWZJT58f9nhyGnsRBqrgwK4W6h4Up"
  @bcat_part "1ChDHzdd1H4wSjgGMHyndZm6qxEDGjqpJL"
  @b "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"


  defimpl Onchain do
    alias Bitcoin.Metanet.B

    def to_data_list(%B{inner: inner, wallet: w}) do
      case inner do
        {:file, path} ->
          B.make_data_list_from_path(path, w)
      end
    end
  end

  def upload(wallet, file_path) do
    %{size: size} = File.stat!(file_path)

    cond do
      size < 95_000 ->
        outputs = [build_output(file_path)]
        Cli.transfer(wallet, outputs)
      true ->
        bcat(wallet, file_path)
    end
  end

  @max_single_b_bytes 95_000

  @doc """
  return a list of opreturn data
  """
  def make_data_list_from_path(path, w) do
    %{size: size} = File.stat!(path)

    cond do
      size < @max_single_b_bytes ->
        [build_single_b_data(path)]
      true ->
        build_bcat_data(path, w)
    end
  end

  def build_single_b_data(path) do
    type = MIME.from_path(path)
    content = File.read!(path)

    [
      @b,
      content,
      type,
      "binary",
      Path.basename(path)
    ]
  end

  def build_output(path) do
    data = build_single_b_data(path)

    %{type: "safe", data: data}
  end

  def bcat(w, path) do
    parts = send_parts(w, path)
    if !Enum.find(parts, fn x -> match?({:error, _}, x) end) do
      send_index(w, path, Enum.map(parts, &elem(&1, 1)))
    else
      {:error, parts}
    end
  end

  defp build_bcat_data(path, w) do
    # parts = parts_tx_and_data(path, w)
    # index = index_data(parts, path)
  end

  # @bcat_part_size 90_000

  # reutrn [%{txid: , raw_tx:}]
  # defp parts_tx_and_data(path, w) do
  #   File.stream!(path, [], @bcat_part_size)
  #   |>

  # end

  def send_parts(w, path) do
    File.stream!(path, [], 90_000)
    |> Stream.map(fn x -> %{type: "safe", data: [@bcat_part, x]} end)
    |> Enum.map(&transfer(&1, w))
  end

  def send_index(w, path, txs) do
    type = MIME.from_path(path)
    name = Path.basename(path)
    %{type: "safe", data: [
      @bcat,
      " ",
      type,
      "binary",
      name,
      " "
    ] ++ Enum.map(txs, &Binary.from_hex/1)
    } |> transfer(w)
  end

  defp transfer(output, wallet) do
    case Bitcoin.Cli.transfer(wallet, [output]) do
      {:ok, _} = resp ->
        resp
      any ->
        IO.inspect any
        # auto retry when error (25 tx limit)
        IO.gets "hit 25 txs limit, press enter to retry"
        transfer(output, wallet)
    end
  end
end
