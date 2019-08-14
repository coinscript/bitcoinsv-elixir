defmodule Bitcoin.Metanet.B do
  @moduledoc """
  B:// protocol.
  """
  alias Bitcoin.Cli

  @bcat "15DHFxWZJT58f9nhyGnsRBqrgwK4W6h4Up"
  @bcat_part "1ChDHzdd1H4wSjgGMHyndZm6qxEDGjqpJL"
  @b "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"

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

  def build_output(file_path) do
    type = MIME.from_path(file_path)
    content = File.read!(file_path)

    data = [
      @b,
      content,
      type,
      "binary",
      Path.basename(file_path)
    ]

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
    Bitcoin.Cli.transfer(wallet, [output])
  end
end
