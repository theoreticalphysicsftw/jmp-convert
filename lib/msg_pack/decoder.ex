defmodule MsgPack.Decoder do
  def decode(<<0b0::size(1), fixint::integer-unsigned-size(7), rest::binary>>) do
    {:ok, fixint, rest}
  end

  def decode(<<0b111::size(3), fixint::integer-unsigned-size(5), rest::binary>>) do
    {:ok, -fixint, rest}
  end

  def decode(<<0xCC::size(8), uint8::integer-unsigned-size(8), rest::binary>>) do
    {:ok, uint8, rest}
  end

  def decode(<<0xCD::size(8), uint16::integer-big-unsigned-size(16), rest::binary>>) do
    {:ok, uint16, rest}
  end

  def decode(<<0xCE::size(8), uint32::integer-big-unsigned-size(32), rest::binary>>) do
    {:ok, uint32, rest}
  end

  def decode(<<0xCF::size(8), uint64::integer-big-unsigned-size(64), rest::binary>>) do
    {:ok, uint64, rest}
  end

  def decode(<<0xD0::size(8), int8::integer-signed-size(8), rest::binary>>) do
    {:ok, int8, rest}
  end

  def decode(<<0xD1::size(8), int16::integer-big-unsigned-size(16), rest::binary>>) do
    {:ok, int16, rest}
  end

  def decode(<<0xD2::size(8), int32::integer-big-signed-size(32), rest::binary>>) do
    {:ok, int32, rest}
  end

  def decode(<<0xD3::size(8), int64::integer-big-signed-size(64), rest::binary>>) do
    {:ok, int64, rest}
  end

  def decode(<<0xCA::size(8), float32::float-big-size(32), rest::binary>>) do
    {:ok, float32, rest}
  end

  def decode(<<0xCB::size(8), float64::float-big-size(64), rest::binary>>) do
    {:ok, float64, rest}
  end

  def decode(<<0xC0::size(8), rest::binary>>) do
    {:ok, nil, rest}
  end

  def decode(<<0xC2::size(8), rest::binary>>) do
    {:ok, false, rest}
  end

  def decode(<<0xC3::size(8), rest::binary>>) do
    {:ok, true, rest}
  end

  def decode(
        <<0b101::size(3), length::integer-unsigned-size(5), str::binary-size(length),
          rest::binary>>
      ) do
    {:ok, str, rest}
  end

  def decode(
        <<0xD9::size(8), length::integer-unsigned-size(8), str::binary-size(length),
          rest::binary>>
      ) do
    {:ok, str, rest}
  end

  def decode(
        <<0xDA::size(8), length::integer-unsigned-big-size(16), str::binary-size(length),
          rest::binary>>
      ) do
    {:ok, str, rest}
  end

  def decode(
        <<0xDB::size(8), length::integer-unsigned-big-size(32), str::binary-size(length),
          rest::binary>>
      ) do
    {:ok, str, rest}
  end

  def decode(
        <<0xC4::size(8), length::integer-unsigned-size(8), bin::binary-size(length),
          rest::binary>>
      ) do
    {:ok, bin, rest}
  end

  def decode(
        <<0xC5::size(8), length::integer-unsigned-big-size(16), bin::binary-size(length),
          rest::binary>>
      ) do
    {:ok, bin, rest}
  end

  def decode(
        <<0xC6::size(8), length::integer-unsigned-big-size(32), bin::binary-size(length),
          rest::binary>>
      ) do
    {:ok, bin, rest}
  end

  def decode(<<0b1001::size(4), length::integer-unsigned-size(4), rest::binary>>) do
    decode_array(length, [], rest)
  end

  def decode(<<0xDC::size(8), length::integer-big-unsigned-size(16), rest::binary>>) do
    decode_array(length, [], rest)
  end

  def decode(<<0xDD::size(8), length::integer-big-unsigned-size(32), rest::binary>>) do
    decode_array(length, [], rest)
  end

  def decode(<<0b1000::size(4), length::integer-unsigned-size(4), rest::binary>>) do
    decode_map(length, %{}, rest)
  end

  def decode(<<0xDE::size(8), length::integer-big-unsigned-size(16), rest::binary>>) do
    decode_map(length, %{}, rest)
  end

  def decode(<<0xDF::size(8), length::integer-big-unsigned-size(32), rest::binary>>) do
    decode_map(length, %{}, rest)
  end

  def decode(_) do
    {:error, :unrecognized_format}
  end

  defp decode_array(0, decoded, data) do
    {:ok, Enum.reverse(decoded), data}
  end

  defp decode_array(length, decoded, data) do
    case decode(data) do
      {:error, error_code} -> {:error, error_code}
      {:ok, element, rest} -> decode_array(length - 1, [element | decoded], rest)
    end
  end

  defp decode_map(0, decoded, rest) do
    {:ok, decoded, rest}
  end

  defp decode_map(length, decoded, data) do
    case decode(data) do
      {:error, error_code} ->
        {:error, error_code}

      {:ok, key, rest} ->
        case decode(rest) do
          {:error, error_code} ->
            {:error, error_code}

          {:ok, value, remaining} ->
            decode_map(length - 1, Map.put(decoded, key, value), remaining)
        end
    end
  end
end
