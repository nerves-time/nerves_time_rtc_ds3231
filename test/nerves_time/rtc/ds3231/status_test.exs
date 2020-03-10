defmodule NervesTime.RTC.DS3231.StatusTest do
  use ExUnit.Case
  alias NervesTime.RTC.DS3231.Status

  test "decode/1 and encode/1" do
    data = %{
      alarm_1_flag: 1,
      alarm_2_flag: 1,
      busy: 1,
      ena_32khz_out: 1,
      osc_stop_flag: 1
    }

    bin = <<0x8F>>
    assert {:ok, data} == Status.decode(bin)
    assert {:ok, bin} == Status.encode(data)
  end
end
