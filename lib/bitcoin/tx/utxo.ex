defmodule Bitcoin.Tx.Utxo do
  defstruct [
    :script_pubkey,
    :hash,
    :value,
    :index
  ]
end
