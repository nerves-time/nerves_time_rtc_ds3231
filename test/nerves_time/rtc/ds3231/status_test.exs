defmodule NervesTime.RTC.DS3231.StatusTest do
  use ExUnit.Case
  alias NervesTime.RTC.DS3231.Status

  test "decodes Status" do
    assert Status.decode(<<0xFF>>) ==
             {:ok,
              %{alarm_1_flag: 1, alarm_2_flag: 1, busy: 1, ena_32khz_out: 1, osc_stop_flag: 1}}
  end
end
