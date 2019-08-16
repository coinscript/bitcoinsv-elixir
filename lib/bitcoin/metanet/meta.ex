defmodule Bitcoin.Metanet.Meta do
  defstruct [
    inner: nil,
    parent_tx: "NULL",
    child_addr: nil
  ]

  alias Bitcoin.Metanet.Onchain

  defimpl Onchain do
    alias Bitcoin.Metanet.Meta

    def to_data_list(%Meta{inner: inner} = m) do
      case inner do
        %{} = p ->
          scripts = Onchain.to_data_list(p)
          # bcat index and parts; or single b data
          [index | others] = scripts

          [meta_data(m, index) | others]
        binary when is_binary(binary) ->
          meta_data(m, binary)
      end
    end

    defp meta_data(m, embed) do
      [
        "meta",
        m.child_addr,
        m.parent_tx,
        embed
      ]
    end

  end
end