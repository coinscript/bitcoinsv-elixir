defmodule Bitcoin.Block.Validation do
  use Bitcoin.Common

  alias Bitcoin.Protocol.Messages.Block

  @spec hash_below_target(Blotk.t()) :: :ok | {:error, term}
  def hash_below_target(%Block{} = block) do
    <<hash_int::unsigned-little-integer-size(256)>> = Bitcoin.Block.hash(block)
    target_int = block.bits |> Bitcoin.Block.CompactBits.decode()
    if hash_int <= target_int, do: :ok, else: {:error, :hash_above_target}
  end

  @spec merkle_root(Blotk.t()) :: :ok | {:error, term}
  def merkle_root(%Block{} = block) do
    if Bitcoin.Block.merkle_root(block) == block.merkle_root do
      :ok
    else
      {:error, :merkle_root_invalid}
    end
  end

  @spec has_parent(Blotk.t()) :: :ok | {:error, term}
  def has_parent(%Block{previous_block: previous_hash} = _block) do
    #  FIXME no need to fetch it, just check it exists
    case Bitcoin.Node.Storage.get_block(previous_hash) do
      nil -> {:error, :no_parent}
      _ -> :ok
    end
  end

  @spec coinbase_value(Block.t()) :: :ok | {:error, term}
  def coinbase_value(block, context \\ %{})

  def coinbase_value(%Block{transactions: []} = _block, _context), do: {:error, :no_coinbase_tx}

  def coinbase_value(%Block{} = block, context) do
    [coinbase | _] = block.transactions
    height = context[:height] || Bitcoin.Node.Storage.block_height(block.previous_block) + 1

    # OPTIMIZE: total fees expensive because we need to fetch all prevouts (which are alse fetched for tx validations)
    if Bitcoin.Tx.total_output_value(coinbase) <=
         max_subsidy_for_height(height) + Bitcoin.Block.total_fees(block, context) do
      :ok
    else
      {:error, :reward_too_high}
    end
  end

  @spec transactions(Block.t()) :: :ok | {:error, term}
  def transactions(%Block{} = block, opts \\ %{}) do
    [_coinbase | transactions] = block.transactions
    opts = opts |> Map.put(:block, block)

    Bitcoin.Util.pmap_reduce(transactions, fn tx -> Bitcoin.Tx.validate(tx, opts) end)
  end

  @spec block_size(Block.t()) :: :ok | {:error, term}
  def block_size(%Block{} = block) do
    # OPTIMIZE we received block serialized, parsed it and now we are serializing it again - it's expensive
    # Parser could put block size in the struct (somewhat redundant)
    # or we could try to pass serialized block here in the opts somehow
    size = block |> Block.serialize() |> byte_size

    if size > @max_block_size do
      {:error, :max_block_size}
    else
      :ok
    end
  end

  # Max block reward allowed for given block height
  def max_subsidy_for_height(height) do
    reward_era = Float.floor(height / @subsidy_halving_interval)
    round(@base_subsidy_value / :math.pow(2, reward_era))
  end
end
