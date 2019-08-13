defmodule Bitcoin.Metanet.Node do
  defstruct [
    :data,
    :txid,
    :parent_txid,
    :address,
    :children_address
  ]
end
