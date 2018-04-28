defprotocol Json.Encoder do
  def encode(object)
end

defimpl Json.Encoder, for: [Integer, Float] do
  def encode(number) do
    to_string(number)
  end
end

defimpl Json.Encoder, for: Atom do
  def encode(nil) do
    "null"
  end

  def encode(atom) do
    to_string(atom)
  end
end

defimpl Json.Encoder, for: List do
  def encode(list) do
    "[" <> Enum.map_join(list, ",", fn x -> Json.Encoder.encode(x) end) <> "]"
  end
end

defimpl Json.Encoder, for: Map do
  def encode(map) do
    "{" <>
      Enum.map_join(map, ",", fn {key, value} ->
        Json.Encoder.encode(key) <> ":" <> Json.Encoder.encode(value)
      end) <> "}"
  end
end

defimpl Json.Encoder, for: BitString do
  def encode(string) do
    "\"" <> encode_chars(string) <> "\""
  end

  defp encode_chars(<<?\\::utf8, rest::binary>>) do
    "\\\\" <> encode_chars(rest)
  end

  defp encode_chars(<<?\n::utf8, rest::binary>>) do
    "\\n" <> encode_chars(rest)
  end

  defp encode_chars(<<?\t::utf8, rest::binary>>) do
    "\\t" <> encode_chars(rest)
  end

  defp encode_chars(<<?\r::utf8, rest::binary>>) do
    "\\r" <> encode_chars(rest)
  end

  defp encode_chars(<<?\f::utf8, rest::binary>>) do
    "\\f" <> encode_chars(rest)
  end

  defp encode_chars(<<?\b::utf8, rest::binary>>) do
    "\\b" <> encode_chars(rest)
  end

  defp encode_chars(<<?"::utf8, rest::binary>>) do
    "\"" <> encode_chars(rest)
  end

  defp encode_chars(<<>>) do
    <<>>
  end

  defp encode_chars(<<char::utf8, rest::binary>>) do
    <<char::utf8>> <> encode_chars(rest)
  end
end
