defmodule Json.Decoder do
  def decode(<<?[::utf8, rest::binary>>) do
    decode_array(String.trim_leading(rest), [])
  end

  # def decode(<<?{::utf8, _::binary>> = string) do 
  # end

  def decode(<<?-::utf8, number::utf8, _::binary>> = string) when number in ?0..?9 do
    decode_number(string)
  end

  def decode(<<number::utf8, _::binary>> = string) when number in ?0..?9 do
    decode_number(string)
  end

  def decode(<<?"::utf8, rest::binary>>) do
    decode_string(rest, <<>>)
  end

  def decode(_) do
    {:error, :invalid_expression}
  end

  defp decode_string(<<?"::utf8, rest::binary>>, decoded) do
    {:ok, decoded, rest}
  end

  defp decode_string(<<>>, _) do
    {:error, :unexpected_end_of_string}
  end

  defp decode_string(<<?\\::utf8, ?n::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> "\n")
  end

  defp decode_string(<<?\\::utf8, ?r::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> "\r")
  end

  defp decode_string(<<?\\::utf8, ?t::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> "\t")
  end

  defp decode_string(<<?\\::utf8, ?b::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> "\b")
  end

  defp decode_string(<<?\\::utf8, ?f::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> "\f")
  end

  defp decode_string(<<?\\::utf8, ?\\::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> "\\")
  end

  defp decode_string(<<?\\::utf8, ?/::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> "/")
  end

  defp decode_string(<<char::utf8, rest::binary>>, decoded) do
    decode_string(rest, decoded <> <<char::utf8>>)
  end

  # Push elements in front of the list then reverse when our job is done.
  defp decode_array(<<?]::utf8, remaining::binary>>, decoded) do
    {:ok, Enum.reverse(decoded), String.trim_leading(remaining)}
  end

  defp decode_array(<<>>, _) do
    {:error, :unexpected_end_of_array}
  end

  defp decode_array(string, decoded) do
    string
    |> decode
    |> case do
      {:error, error_code} ->
        {:error, error_code}

      {:ok, decoded_value, remaining} ->
        remaining
        |> String.trim_leading()
        |> case do
          <<?,::utf8, next_elements::binary>> ->
            decode_array(String.trim_leading(next_elements), [decoded_value | decoded])

          done_or_error ->
            decode_array(done_or_error, [decoded_value | decoded])
        end
    end
  end

  defp decode_number(string) do
    string
    |> Integer.parse()
    |> case do
      :error ->
        {:error, :invalid_number_expression}

      {_, <<?.::utf8, _::binary>>} ->
        decode_float(string)

      {_, <<?E::utf8, _::binary>>} ->
        decode_float(string)

      {_, <<?e::utf8, _::binary>>} ->
        decode_float(string)

      {integer, remaining} ->
        {:ok, integer, remaining}
    end
  end

  defp decode_float(string) do
    Float.parse(string)
    |> case do
      :error ->
        {:error, :invalid_number_expression}

      {value, rest} ->
        {:ok, value, rest}
    end
  end
end
