defmodule Json do
  alias Json.Decoder

  def decode_strict(string) do
    case Decoder.decode(String.trim_leading(string)) do
      {:error, error_code} -> {:error, error_code}
      {:ok, decoded, <<>>} -> {:ok, decoded}
      _ -> {:error, :data_after_end_of_expression}
    end
  end

  def decode(string) do
    Decoder.decode(String.trim_leading(string))
  end
end
