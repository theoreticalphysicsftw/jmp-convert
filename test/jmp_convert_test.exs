defmodule JmpConvertTest do
  use ExUnit.Case
  doctest JmpConvert

  test "decodes negative integers" do
    assert JmpConvert.decode_json_strict("-1337") == {:ok, -1337}
  end

  test "decodes positive integers" do
    assert JmpConvert.decode_json_strict("666") == {:ok, 666}
  end

  test "fails on invalid integers" do
    assert JmpConvert.decode_json_strict("p666") == {:error, :invalid_expression}
  end

  test "decodes Plank's constant" do
    assert JmpConvert.decode_json_strict("6.626e34") == {:ok, 6.626e34}
  end

  test "handles whitespaces" do
    assert JmpConvert.decode_json_strict("  [ 1,   2,      [  ]\n ]") == {:ok, [1, 2, []]}
  end

  test "decodes strings" do
    assert JmpConvert.decode_json_strict("\"string\"") == {:ok, "string"}
  end

  test "decodes arrays" do
    assert JmpConvert.decode_json_strict("[[],[[],[[[[]]],[]]]]") ==
             {:ok, [[], [[], [[[[]]], []]]]}
  end
end
