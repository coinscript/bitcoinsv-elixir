defmodule BitcoinTest.Protocol.Types.IntegerArrayTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Types.IntegerArray

  test "returns an empty array and the remaining payload for a size zero array" do
    # element count
    payload =
      <<
        0,
        # remaining stream
        1,
        1,
        0
      >>

    assert {[], <<1, 1, 0>>} ==
             IntegerArray.parse_stream(payload)
  end

  test "returns an array of size one" do
    # element count
    payload =
      <<
        1,
        # first element
        1::unsigned-little-integer-size(32),
        # remaining stream
        0,
        1,
        0
      >>

    assert {
             [
               1
             ],
             <<0, 1, 0>>
           } ==
             IntegerArray.parse_stream(payload)
  end

  test "returns an array of size two" do
    # element count
    payload =
      <<
        2,
        # first element
        1::unsigned-little-integer-size(32),
        # second element
        56619::unsigned-little-integer-size(32),
        # remaining stream
        1,
        1,
        0
      >>

    assert {
             [
               1,
               56619
             ],
             <<1, 1, 0>>
           } ==
             IntegerArray.parse_stream(payload)
  end

  test "returns an array of size three" do
    # element count
    payload =
      <<
        3,
        # elements
        1::unsigned-little-integer-size(32),
        56619::unsigned-little-integer-size(32),
        1_305_992_491::unsigned-little-integer-size(32),
        # remaining stream
        1,
        1,
        1
      >>

    assert {
             [
               1,
               56619,
               1_305_992_491
             ],
             <<1, 1, 1>>
           } ==
             IntegerArray.parse_stream(payload)
  end
end
