defmodule JmpConvert do
  @moduledoc """
  Simple library for converting between MsgPack, JSON, and elixir objects.
  """

  @doc """
  Transforms JSON to MessagePack

  ## Examples
      
      iex> JmpConvert.json_to_msg_pack("{\\\"usability\\\": null}")
      {:ok, <<0x81, 0xa9, 0x75, 0x73, 0x61, 0x62, 0x69, 0x6c, 0x69, 0x74, 0x79, 0xc0>>,""}
  """
  def json_to_msg_pack(json) do
    case Json.decode(json) do
      {:error, error_code} -> {:error, error_code}
      {:ok, result, rest} -> {:ok, MsgPack.encode(result), rest}
    end
  end

  @doc """
  Transforms MessagePack to JSON

  ## Examples
      
      iex> JmpConvert.msg_pack_to_json(<<0x81, 0xa9, 0x75, 0x73, 0x61, 0x62, 0x69, 0x6c, 0x69, 0x74, 0x79, 0xc0>>)
      {:ok, "{\\\"usability\\\":null}",""}
  """
  def msg_pack_to_json(msg_pack) do
    case MsgPack.decode(msg_pack) do
      {:error, error_code} -> {:error, error_code}
      {:ok, result, rest} -> {:ok, Json.encode(result), rest}
    end
  end
end
