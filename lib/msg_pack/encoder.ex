defprotocol MsgPack.Encoder do
  def encode(object)
end

defmodule EncodeHelper do
  def power_of_two(0) do
    1
  end

  def power_of_two(x) when rem(x, 2) == 0 do
    x = power_of_two(div(x, 2))
    x * x
  end

  def power_of_two(x) do
    2 * power_of_two(x - 1)
  end

  defmacro power_of_two_ct(x) do
    quote do
      unquote(power_of_two(x))
    end
  end
end

defimpl MsgPack.Encoder, for: Integer do
  require EncodeHelper

  def encode(number) when number > 0 do
    cond do
      number < EncodeHelper.power_of_two_ct(7) ->
        <<0b0::size(1), number::integer-unsigned-size(7)>>

      number < EncodeHelper.power_of_two_ct(8) ->
        <<0xCC::size(8), number::integer-unsigned-size(8)>>

      number < EncodeHelper.power_of_two_ct(16) ->
        <<0xCD::size(8), number::integer-big-unsigned-size(16)>>

      number < EncodeHelper.power_of_two_ct(32) ->
        <<0xCD::size(8), number::integer-big-unsigned-size(32)>>

      number < EncodeHelper.power_of_two_ct(64) ->
        <<0xCF::size(8), number::integer-big-unsigned-size(64)>>
    end
  end

  def encode(number) do
    cond do
      -number < EncodeHelper.power_of_two_ct(5) ->
        <<0b111::size(3), -number::integer-signed-size(5)>>

      -number < EncodeHelper.power_of_two_ct(8) ->
        <<0xCF::size(8), number::integer-signed-size(8)>>

      -number < EncodeHelper.power_of_two_ct(16) ->
        <<0xCD::size(8), number::integer-big-signed-size(16)>>

      -number < EncodeHelper.power_of_two_ct(32) ->
        <<0xCD::size(8), number::integer-big-signed-size(32)>>

      -number < EncodeHelper.power_of_two_ct(64) ->
        <<0xCF::size(8), number::integer-big-signed-size(64)>>
    end
  end

  defimpl MsgPack.Encoder, for: Float do
    def encode(float) do
      <<0xCB::size(8), float::float-big-size(64)>>
    end
  end

  defimpl MsgPack.Encoder, for: Bool do
    def encode(false) do
      <<0xC2::size(8)>>
    end

    def encode(true) do
      <<0xC3::size(8)>>
    end
  end

  defimpl MsgPack.Encoder, for: Atom do
    def encode(nil) do
      <<0xC0::size(8)>>
    end

    def encode(false) do
      <<0xC2::size(8)>>
    end

    def encode(true) do
      <<0xC3::size(8)>>
    end
  end

  defimpl MsgPack.Encoder, for: List do
    defp encode_list(list) do
      Enum.map_join(list, fn x -> MsgPack.Encoder.encode(x) end)
    end

    def encode(list) do
      len = length(list)

      cond do
        len < EncodeHelper.power_of_two_ct(4) ->
          <<0b1001::size(4), len::unsigned-integer-size(4), encode_list(list)::binary>>

        len < EncodeHelper.power_of_two_ct(16) ->
          <<0xDC::size(8), len::unsigned-integer-size(16), encode_list(list)::binary>>

        len < EncodeHelper.power_of_two_ct(32) ->
          <<0xDD::size(8), len::unsigned-integer-size(32), encode_list(list)::binary>>
      end
    end
  end

  defimpl MsgPack.Encoder, for: Map do
    defp encode_map(map) do
      Enum.map_join(map, fn {key, value} ->
        MsgPack.Encoder.encode(key) <> MsgPack.Encoder.encode(value)
      end)
    end

    def encode(map) do
      size = Map.size(map)

      cond do
        size < EncodeHelper.power_of_two_ct(4) ->
          <<0b1000::size(4), size::unsigned-integer-size(4), encode_map(map)::binary>>

        size < EncodeHelper.power_of_two_ct(16) ->
          <<0xDE::size(8), size::unsigned-integer-size(16), encode_map(map)::binary>>

        size < EncodeHelper.power_of_two_ct(32) ->
          <<0xDF::size(8), size::unsigned-integer-size(32), encode_map(map)::binary>>
      end
    end
  end

  defimpl MsgPack.Encoder, for: BitString do
    def encode(<<string::binary>>) do
      size = byte_size(string)

      cond do
        size < EncodeHelper.power_of_two_ct(4) ->
          <<0b101::size(3), size::unsigned-integer-size(5), string::binary>>

        size < EncodeHelper.power_of_two_ct(8) ->
          <<0xD9::size(8), size::unsigned-integer-size(8), string::binary>>

        size < EncodeHelper.power_of_two_ct(16) ->
          <<0xDA::size(8), size::unsigned-integer-size(16), string::binary>>

        size < EncodeHelper.power_of_two_ct(32) ->
          <<0xDB::size(8), size::unsigned-integer-size(32), string::binary>>
      end
    end
  end
end
