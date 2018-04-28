defmodule MsgPack do
  alias MsgPack.Decoder
  alias MsgPack.Encoder

  @doc """
  Decodes MessagePack object to internal elixir object.
  This function fails returning error if there is data after valid MessagePack expression.

  ## Examples

      iex> MsgPack.decode_strict(<<0x92, 0x90, 0x93, 0x93, 0x01, 0x02, 0x03, 0xa3, 0x61, 0x62, 0x63, 0xcf, 0x44, 0xdf, 0xde, 0x9f, 0x10, 0xa8, 0xd4, 0x00>>)
      {:ok, [[], [[1, 2, 3], "abc", 4962930089146242048]]}
      
      iex> MsgPack.decode_strict(<<0x92, 0x90, 0x93, 0x93, 0x01, 0x02, 0x03, 0xa3, 0x61, 0x62, 0x63, 0xcf, 0x44, 0xdf, 0xde, 0x9f, 0x10, 0xa8, 0xd4, 0x00>> <> "garbage")
      {:error, :data_after_end_of_expression}
  """
  def decode_strict(binary) do
    case Decoder.decode(binary) do
      {:error, error_code} -> {:error, error_code}
      {:ok, decoded, <<>>} -> {:ok, decoded}
      _ -> {:error, :data_after_end_of_expression}
    end
  end

  @doc """
  Similar to decode_strict but returns the rest of the data after each valid expression,
  skipping whitespaces instead of returning error.

  ## Examples
      
      iex> MsgPack.decode(<<0x92, 0x90, 0x93, 0x93, 0x01, 0x02, 0x03, 0xa3, 0x61, 0x62, 0x63, 0xcf, 0x44, 0xdf, 0xde, 0x9f, 0x10, 0xa8, 0xd4, 0x00>> <> "garbage")
      {:ok, [[], [[1, 2, 3], "abc", 4962930089146242048]], "garbage"}
  """
  def decode(binary) do
    Decoder.decode(binary)
  end

  @doc """
  Encodes some native elixir objects into MsgPack.

  ## Examples
      
      iex> MsgPack.encode(%{"key0" => [1,2,3], "key1" => "abc"})
      <<0x82, 0xa4, 0x6b, 0x65, 0x79, 0x30, 0x93, 0x01, 0x02, 0x03, 0xa4, 0x6b, 0x65, 0x79, 0x31, 0xa3, 0x61, 0x62, 0x63>>
  """
  def encode(object) do
    Encoder.encode(object)
  end
end
