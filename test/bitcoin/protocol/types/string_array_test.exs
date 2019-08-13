defmodule BitcoinTest.Protocol.Types.StringArrayTest do
  use ExUnit.Case

  alias Bitcoin.Protocol.Types.StringArray

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
             StringArray.parse_stream(payload)
  end

  test "returns an array of size one with string char 1 'a' and the remaining payload" do
    # element count
    payload =
      <<
        1,
        # first element, << Integer byte count, string 'a' >>
        1,
        97,
        # remaining stream
        0,
        1,
        0
      >>

    assert {
             [
               "a"
             ],
             <<0, 1, 0>>
           } ==
             StringArray.parse_stream(payload)
  end

  test "returns an array of size two with string char 1 'a' and string char 0 and the remaining payload" do
    # element count
    payload =
      <<
        2,
        # first element, << Integer byte count, string 'a' >>
        1,
        97,
        # second element, empty string
        0,
        # remaining stream
        1,
        1,
        0
      >>

    assert {
             [
               "a",
               ""
             ],
             <<1, 1, 0>>
           } ==
             StringArray.parse_stream(payload)
  end

  test "returns an array of size three with properly int(8), int(16), int(32) and the remaining payload" do
    # element count
    payload =
      <<
        3,
        # first element, << Integer byte count, string 'a' >>
        1,
        97,
        # second element, empty string
        0,
        # third element, << Integer byte count, string 'ab' >>
        2,
        97,
        98,
        # remaining stream
        1,
        1,
        1
      >>

    assert {
             [
               "a",
               "",
               "ab"
             ],
             <<1, 1, 1>>
           } ==
             StringArray.parse_stream(payload)
  end
end
