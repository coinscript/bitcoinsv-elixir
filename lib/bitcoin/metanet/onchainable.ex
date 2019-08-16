defprotocol Bitcoin.Metanet.Onchain do

  @doc """
  %Meta{
    inner:
      %B{
        inner: {:file, "path/to/file.txt"}
      }
  } |> to_data_list
  == <<...>>
  """
  def to_data_list(term)

end