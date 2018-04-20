defmodule JmpConvertTest do
  use ExUnit.Case
  doctest JmpConvert
  doctest Json

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
end
