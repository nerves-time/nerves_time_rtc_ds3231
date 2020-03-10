defmodule NervesTime.RTC.DS3231.ControlTest do
  use ExUnit.Case
  alias NervesTime.RTC.DS3231.Control

  test "decode/1 and encode/1" do
    data = %{
      alarm_1_int_ena: 1,
      alarm_2_int_ena: 1,
      bbsqw: 1,
      conv_temp: 1,
      interrupt_control: 1,
      rate_sel_0: 1,
      rate_sel_1: 1,
      osc_enable_: 1
    }

    bin = <<255>>
    assert {:ok, bin} == Control.encode(data)
    assert {:ok, data} == Control.decode(bin)

    data = %{
      alarm_1_int_ena: 0,
      alarm_2_int_ena: 0,
      bbsqw: 0,
      conv_temp: 0,
      interrupt_control: 0,
      rate_sel_0: 0,
      rate_sel_1: 0,
      osc_enable_: 0
    }

    bin = <<0>>
    assert {:ok, bin} == Control.encode(data)
    assert {:ok, data} == Control.decode(bin)
  end
end
