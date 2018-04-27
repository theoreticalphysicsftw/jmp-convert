defprotocol MsgPack.Encoder do
  def encode(object)
end

defimpl MsgPack.Encoder, for: Integer do
  defp power_of_two(0) do
    1
  end

  defp power_of_two(x) when rem(x, 2) == 0 do
    x = power_of_two(div(x, 2))
    x * x
  end

  defp power_of_two(x) do
    2 * power_of_two(x - 1)
  end

  defmacrop power_of_two_ct(x) do
    quote do
      unquote(power_of_two(x))
    end
  end

  def encode(number) when number > 0 do
    cond do
      number <= power_of_two_ct(7) ->
        <<0b0::size(1), number::integer-unsigned-size(7)>>

      number <= power_of_two_ct(8) ->
        <<0xCC::size(8), number::integer-unsigned-size(8)>>

      number <= power_of_two_ct(16) ->
        <<0xCD::size(8), number::integer-big-unsigned-size(16)>>

      number <= power_of_two_ct(32) ->
        <<0xCD::size(8), number::integer-big-unsigned-size(32)>>

      number <= power_of_two_ct(64) ->
        <<0xCF::size(8), number::integer-big-unsigned-size(64)>>
    end
  end

  def encode(number) do
    cond do
      -number <= power_of_two_ct(5) ->
        <<0b111::size(3), -number::integer-signed-size(5)>>

      -number <= power_of_two_ct(8) ->
        <<0xCF::size(8), number::integer-signed-size(8)>>

      -number <= power_of_two_ct(16) ->
        <<0xCD::size(8), number::integer-big-signed-size(16)>>

      -number <= power_of_two_ct(32) ->
        <<0xCD::size(8), number::integer-big-signed-size(32)>>

      -number <= power_of_two_ct(64) ->
        <<0xCF::size(8), number::integer-big-signed-size(64)>>
    end
  end

  defimpl MsgPack.Encoder, for: Float do
    def encode(float) do
      <<0xCB::size(8), float::float-big-size(64)>>
    end
  end
end
