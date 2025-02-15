defmodule Bitcoin.Key.Public do
  @moduledoc """
  Public key operations.
  """

  use Bitcoin.Common

  alias Bitcoin.Crypto
  alias Bitcoin.Base58Check

  @type t :: binary

  @doc """
  Check if public key is in either compressed or uncompressed format.

  Used for validation with the STRICTENC flag.
  """
  @spec strict?(t) :: boolean
  def strict?(pk) do
    cond do
      # Too short
      byte_size(pk) < 33 ->
        false

      # Invaild length for uncompressed key
      Binary.at(pk, 0) == 0x04 && byte_size(pk) != 65 ->
        false

      # Invalid length for compressed key
      Binary.at(pk, 0) in [0x02, 0x03] && byte_size(pk) != 33 ->
        false

      # Non-canonical: neither compressed nor uncompressed
      !(Binary.at(pk, 0) in [0x02, 0x03, 0x04]) ->
        false

      # Everything ok
      true ->
        true
    end
  end

  @doc """
  Convert public key into a Bitcoin address.

  Details can be found here: https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
  """
  @spec to_address(t) :: binary
  def to_address(pk) do
    pk
    |> Crypto.sha256()
    |> Crypto.ripemd160()
    |> Binary.prepend(@address_prefix[:public])
    |> Base58Check.encode()
  end
end
