defmodule JmpConvert do
  @moduledoc """
  Simple library for converting between MsgPack, JSON, and elixir objects.
  """

  @doc """
  Decodes JSON object to internal elixir object.
  This function fails returning error if there is data after valid JSON expression.

  ## Examples

      iex> JmpConvert.decode_json_strict("[[], [[1, 2, 3], \\\"abc\\\", 6.02e23]]")
      {:ok, [[], [[1, 2, 3], "abc", 6.02e23]]}
      
      iex> JmpConvert.decode_json_strict("[[], [[1, 2, 3], \\\"abc\\\", 6.02e23]] garbage")
      {:error, :data_after_end_of_expression}
  """
  def decode_json_strict(string) do
    Json.decode_strict(string)
  end

  @doc """
  Similar to decode_json_strict but returns the rest of the data after each valid expression,
  skipping whitespaces instead of returning error.

  ## Examples
      
      iex> JmpConvert.decode_json("[[], [[1, 2, 3], \\\"abc\\\", 6.02e23]] garbage")
      {:ok, [[], [[1, 2, 3], "abc", 6.02e23]], "garbage"}
  """
  def decode_json(string) do
    Json.decode(string)
  end
end
