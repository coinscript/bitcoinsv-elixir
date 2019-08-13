defmodule Bitcoin.Metanet.B do
  @moduledoc """
  B:// protocol.
  """
  alias Bitcoin.Cli

  def upload(wallet, file_path) do
    outputs = [build_b(file_path)]
    Cli.transfer(wallet, outputs)
  end

  def build_b(file_path) do
    type = MIME.from_path(file_path)
    content = File.read!(file_path)

    data = [
      "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut",
      content,
      type,
      "binary",
      Path.basename(file_path)
    ]

    %{type: "safe", data: data}
  end
end
