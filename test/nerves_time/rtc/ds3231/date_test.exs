defmodule NervesTime.RTC.DS3231.DateTest do
  use ExUnit.Case
  alias NervesTime.RTC.DS3231.Date

  @century_0 2000
  @century_1 2100

  test "century_0 support" do
    # The dates tested here must be `>= @century_0 and < @century_1`.
    assert_encode_decode(~N[2000-01-01 00:00:00], <<0, 0, 0, 6, 1, 1, 0>>)
    assert_encode_decode(~N[2050-06-16 12:30:30], <<48, 48, 18, 4, 22, 6, 80>>)
    assert_encode_decode(~N[2099-12-31 23:59:59], <<89, 89, 35, 4, 49, 18, 153>>)
  end

  test "century_1 support" do
    # The dates tested here must be `>= @century_1 and < @century_1 + 100`.
    assert_encode_decode(~N[2100-01-01 00:00:00], <<0, 0, 0, 5, 1, 129, 0>>)
    assert_encode_decode(~N[2150-06-16 12:30:30], <<48, 48, 18, 2, 22, 134, 80>>)
    assert_encode_decode(~N[2199-12-31 23:59:59], <<89, 89, 35, 2, 49, 146, 153>>)
  end

  defp assert_encode_decode(date, bin) do
    assert {:ok, bin} == Date.encode(date, @century_0, @century_1)
    assert {:ok, date} == Date.decode(bin, @century_0, @century_1)
  end
end
