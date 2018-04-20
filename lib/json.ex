defmodule Json do
  alias Json.Decoder

  @doc """
  Decodes JSON object to internal elixir object.
  This function fails returning error if there is data after valid JSON expression.

  ## Examples

      iex> JmpConvert.decode_json_strict("[[], [[1, 2, 3], \\\"abc\\\", 6.02e23]]")
      {:ok, [[], [[1, 2, 3], "abc", 6.02e23]]}
      
      iex> JmpConvert.decode_json_strict("[[], [[1, 2, 3], \\\"abc\\\", 6.02e23]] garbage")
      {:error, :data_after_end_of_expression}
  """
  def decode_strict(string) do
    case Decoder.decode(String.trim_leading(string)) do
      {:error, error_code} -> {:error, error_code}
      {:ok, decoded, <<>>} -> {:ok, decoded}
      _ -> {:error, :data_after_end_of_expression}
    end
  end

  @doc """
  Similar to decode_json_strict but returns the rest of the data after each valid expression,
  skipping whitespaces instead of returning error.

  ## Examples
      
      iex> JmpConvert.decode_json("[[], [[1, 2, 3], \\\"abc\\\", 6.02e23]] garbage")
      {:ok, [[], [[1, 2, 3], "abc", 6.02e23]], "garbage"}
  """
  def decode(string) do
    Decoder.decode(String.trim_leading(string))
  end
end
