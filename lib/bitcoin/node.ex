defmodule Bitcoin.Node do
  @moduledoc """
  GenServer representing a single running Bitcoin node.

  Node can be configured with `config :bittcoin, :node` options
  which are documented in the config.exs file
  """

  use Bitcoin.Common
  use GenServer

  require Logger

  @default_config %{
    listen_ip: '0.0.0.0',
    listen_port: @default_listen_port,
    max_connections: 8,
    user_agent: "/bitcoin-elixir:0.0.0/",
    data_directory: Path.expand("~/.bitcoin-elixir/#{@network}"),
    # TODO probably doesn't belong to config
    services: <<1, 0, 0, 0, 0, 0, 0, 0>>
  }

  @protocol_version 70002

  # Interface

  @doc """
  Start the node. Startup options are read from the config.
  """
  @spec start_link() :: {:ok, pid} | {:error, term}
  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @doc """
  Used by peer to provide fields for the VERSION message.
  """
  def version_fields, do: GenServer.call(__MODULE__, :version_fields)

  @doc """
  Returns the config (congif.exs on top of the default config)
  """
  def config, do: GenServer.call(__MODULE__, :config)

  @doc """
  Returns the nonce.

  Nonce is generated at the node startup and used by peers to detect self connections.
  """
  def nonce, do: GenServer.call(__MODULE__, :nonce)
  def height, do: 1
  def protocol_version, do: @protocol_version

  # Implementation

  def init(_) do
    self() |> send(:initialize)
    {:ok, %{}}
  end

  def handle_info(:initialize, state) do
    Logger.info("Node initialization")

    config =
      case Application.fetch_env(:bitcoin, :node) do
        :error ->
          @default_config

        {:ok, config} ->
          @default_config |> Map.merge(config |> Enum.into(%{}))
      end

    File.mkdir_p(config.data_directory)

    state =
      state
      |> Map.merge(%{
        nonce: Bitcoin.Util.nonce64(),
        config: config
      })

    {:noreply, state}
  end

  def handle_call(:config, _from, state), do: {:reply, state.config, state}
  def handle_call(:nonce, _from, state), do: {:reply, state.nonce, state}

  def handle_call(:version_fields, _from, state) do
    fields = %{
      height: height(),
      nonce: state.nonce,
      relay: true,
      services: <<1, 0, 0, 0, 0, 0, 0, 0>>,
      timestamp: timestamp(),
      version: @protocol_version,
      user_agent: state.config[:user_agent]
    }

    {:reply, fields, state}
  end

  @doc """
  Timestamp in UTC seconds. It's used to validate sanity of other peers and blockhain data.

  Check `Bitcoin.Util.militime` for more accurate timestamp.
  """
  def timestamp do
    {megas, s, _milis} = :os.timestamp()
    round(1.0e6 * megas + s)
  end
end
