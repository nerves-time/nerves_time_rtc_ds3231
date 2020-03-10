defmodule NervesTime.RTC.DS3231.AlarmTest do
  use ExUnit.Case
  alias NervesTime.RTC.DS3231.Alarm

  describe "decode/1 and encode/1" do
    test "alarm_1" do
      alarm_1 = %{
        alarm_1_mask_1: 0,
        alarm_1_mask_2: 1,
        alarm_1_mask_3: 0,
        alarm_1_mask_4: 1,
        seconds: 1,
        minutes: 2,
        hours: 3,
        day: 20
      }

      bin_1 = <<1, 130, 3, 160>>
      assert {:ok, bin_1} == Alarm.encode(alarm_1)
      assert {:ok, alarm_1} == Alarm.decode(bin_1)

      alarm_1 = %{
        alarm_1_mask_1: 1,
        alarm_1_mask_2: 0,
        alarm_1_mask_3: 1,
        alarm_1_mask_4: 0,
        seconds: 3,
        minutes: 5,
        hours: 9,
        day: 16
      }

      bin_1 = <<131, 5, 137, 22>>
      assert {:ok, bin_1} == Alarm.encode(alarm_1)
      assert {:ok, alarm_1} == Alarm.decode(bin_1)
    end

    test "alarm_2" do
      alarm_2 = %{
        alarm_2_mask_1: 0,
        alarm_2_mask_2: 1,
        alarm_2_mask_3: 0,
        minutes: 2,
        hours: 3,
        day: 20
      }

      bin_2 = <<2, 131, 32>>
      assert {:ok, bin_2} == Alarm.encode(alarm_2)
      assert {:ok, alarm_2} == Alarm.decode(bin_2)

      alarm_2 = %{
        alarm_2_mask_1: 1,
        alarm_2_mask_2: 0,
        alarm_2_mask_3: 1,
        minutes: 55,
        hours: 43,
        day: 30
      }

      bin_2 = <<213, 67, 176>>
      assert {:ok, bin_2} == Alarm.encode(alarm_2)
      assert {:ok, alarm_2} == Alarm.decode(bin_2)
    end
  end
end
