defmodule NervesTime.RTC.DS3231.DateTest do
  use ExUnit.Case
  alias NervesTime.RTC.DS3231.Date

  test "decodes date" do
    assert Date.decode(<<2, 3, 4, 1, 5, 6, 7>>) ==
             {:ok, ~N[2007-06-05 04:03:02]}
  end

  test "encodes date" do
    assert Date.encode(~N[2007-06-05 04:03:02.49]) ==
             {:ok, <<2, 3, 4, 2, 5, 6, 7>>}

    assert Date.encode(~N[2019-10-04 00:07:18.49]) ==
             {:ok, <<0x18, 0x07, 0x00, 0x05, 0x04, 0x10, 0x19>>}
  end

  test "non-21st century dates return errors when encoded" do
    assert Date.encode(~N[1970-01-01 00:00:11.809623]) == {:error, :invalid_date}
  end
end
