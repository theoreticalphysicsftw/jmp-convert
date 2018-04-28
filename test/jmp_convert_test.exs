defmodule JmpConvertTest do
  use ExUnit.Case
  doctest JmpConvert
  doctest Json
  doctest MsgPack

  test "decodes negative integers" do
    assert Json.decode_strict("-1337") == {:ok, -1337}
  end

  test "decodes positive integers" do
    assert Json.decode_strict("666") == {:ok, 666}
  end

  test "fails on invalid integers" do
    assert Json.decode_strict("p666") == {:error, :invalid_expression}
  end

  test "decodes Plank's constant" do
    assert Json.decode_strict("6.626e34") == {:ok, 6.626e34}
  end

  test "handles whitespaces" do
    assert Json.decode_strict("  [ 1,   2,      [  ]\n ]") == {:ok, [1, 2, []]}
  end

  test "decodes strings" do
    assert Json.decode_strict("\"string\"") == {:ok, "string"}
  end

  test "decodes arrays" do
    assert Json.decode_strict("[[],[[],[[[[]]],[]]]]") == {:ok, [[], [[], [[[[]]], []]]]}
  end

  test "decodes maps" do
    assert Json.decode_strict("{\"key0\": [\"value0\"], \"key1\": {\"v\" : 3}}") ==
             {:ok, %{"key0" => ["value0"], "key1" => %{"v" => 3}}}
  end

  test "handles bad map key" do
    assert Json.decode_strict("{123 : 123}") == {:error, :invalid_expression}
  end

  test "handles bad map key value separator" do
    assert Json.decode_strict("{123 [ 123}") == {:error, :invalid_expression}
  end

  test "encodes integers" do
    assert Json.encode(-1) == "-1"
  end

  test "encodes floats" do
    assert Json.encode(0.0) == "0.0"
  end

  test "encodes strings" do
    assert Json.encode("string") == "\"string\""
  end

  test "encodes arrays" do
    assert Json.encode([[], [[], [[[[]]], []]]]) == "[[],[[],[[[[]]],[]]]]"
  end

  test "encodes maps" do
    assert Json.encode(%{"key0" => ["value0"], "key1" => %{"v" => 3}}) ==
             "{\"key0\":[\"value0\"],\"key1\":{\"v\":3}}"
  end

  test "inverse integer test" do
    assert MsgPack.decode(MsgPack.encode(666)) == {:ok, 666, ""}
  end

  test "inverse float test" do
    assert MsgPack.decode(MsgPack.encode(6.02e23)) == {:ok, 6.02e23, ""}
  end

  test "inverse string test" do
    assert MsgPack.decode(MsgPack.encode("str")) == {:ok, "str", ""}
  end

  test "inverse array test" do
    assert MsgPack.decode(MsgPack.encode([1, 2, 3])) == {:ok, [1, 2, 3], ""}
  end

  test "inverse map test" do
    assert MsgPack.decode(MsgPack.encode(%{"a" => 1, "b" => 2})) ==
             {:ok, %{"a" => 1, "b" => 2}, ""}
  end

  test "inverse nested structure test" do
    assert MsgPack.decode(
             MsgPack.encode(%{
               "a" => [1, 2, nil, %{false => "a", [nil, 1] => "З"}],
               1 => [1, "abc", [], [[[]]]]
             })
           ) ==
             {:ok,
              %{
                "a" => [1, 2, nil, %{false => "a", [nil, 1] => "З"}],
                1 => [1, "abc", [], [[[]]]]
              }, ""}
  end

  test "conversion inverse integer test" do
    y = "666"
    {:ok, x, _} = JmpConvert.json_to_msg_pack(y)
    assert JmpConvert.msg_pack_to_json(x) == {:ok, y, ""}
  end

  test "conversion inverse float test" do
    y = "6.02e23"
    {:ok, x, _} = JmpConvert.json_to_msg_pack(y)
    assert JmpConvert.msg_pack_to_json(x) == {:ok, y, ""}
  end

  test "conversion inverse string test" do
    y = "\"абвгдежз\""
    {:ok, x, _} = JmpConvert.json_to_msg_pack(y)
    assert JmpConvert.msg_pack_to_json(x) == {:ok, y, ""}
  end

  test "conversion inverse array test" do
    y = "[6,6,6]"
    {:ok, x, _} = JmpConvert.json_to_msg_pack(y)
    assert JmpConvert.msg_pack_to_json(x) == {:ok, y, ""}
  end

  test "conversion inverse map test" do
    y = "{\"0\":[1,2,3],\"X\":4}"
    {:ok, x, _} = JmpConvert.json_to_msg_pack(y)
    assert JmpConvert.msg_pack_to_json(x) == {:ok, y, ""}
  end

  test "conversion inverse nested structure test" do
    y = "{\"0\":[{\"key\":[\"abc\",false],\"t\":null},2,3],\"X\":{\"Y\":{\"Z\":[null]}}}"
    {:ok, x, _} = JmpConvert.json_to_msg_pack(y)
    assert JmpConvert.msg_pack_to_json(x) == {:ok, y, ""}
  end
end
