# SPDX-FileCopyrightText: 2020 Daniel Spofford
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule NervesTime.RTC.DS3231.Alarm do
  @moduledoc false

  alias NervesTime.RealTimeClock.BCD

  @typedoc "The DS3231 alarm registers are a 4-byte or 3-byte binary."
  @type alarm_registers() :: <<_::4>> | <<_::3>>

  @doc """
  Decode register values into an alarm.
  """
  @spec decode(alarm_registers()) :: {:ok, map()} | {:error, any()}
  def decode(
        <<
          alarm_1_mask_1::1,
          seconds::7,
          alarm_1_mask_2::1,
          minutes::7,
          alarm_1_mask_3::1,
          hours::7,
          alarm_1_mask_4::1,
          day::7
        >> = _alarm_1
      ) do
    alarm_1 = %{
      alarm_1_mask_1: alarm_1_mask_1,
      alarm_1_mask_2: alarm_1_mask_2,
      alarm_1_mask_3: alarm_1_mask_3,
      alarm_1_mask_4: alarm_1_mask_4,
      seconds: BCD.to_integer(seconds),
      minutes: BCD.to_integer(minutes),
      hours: BCD.to_integer(hours),
      day: BCD.to_integer(day)
    }

    {:ok, alarm_1}
  end

  def decode(
        <<alarm_2_mask_1::1, minutes::7, alarm_2_mask_2::1, hours::7, alarm_2_mask_3::1, day::7>> =
          _alarm_2
      ) do
    alarm_2 = %{
      alarm_2_mask_1: alarm_2_mask_1,
      alarm_2_mask_2: alarm_2_mask_2,
      alarm_2_mask_3: alarm_2_mask_3,
      minutes: BCD.to_integer(minutes),
      hours: BCD.to_integer(hours),
      day: BCD.to_integer(day)
    }

    {:ok, alarm_2}
  end

  def decode(_), do: {:error, :invalid}

  @doc """
  Encode `alarm` to register values.
  """
  @spec encode(map()) :: {:ok, alarm_registers()} | {:error, :invalid}
  def encode(%{
        alarm_1_mask_1: a1m1,
        alarm_1_mask_2: a1m2,
        alarm_1_mask_3: a1m3,
        alarm_1_mask_4: a1m4,
        day: day,
        hours: hours,
        minutes: minutes,
        seconds: seconds
      }) do
    seconds = BCD.from_integer(seconds)
    minutes = BCD.from_integer(minutes)
    hours = BCD.from_integer(hours)
    day = BCD.from_integer(day)
    bin = <<a1m1::1, seconds::7, a1m2::1, minutes::7, a1m3::1, hours::7, a1m4::1, day::7>>
    {:ok, bin}
  end

  def encode(%{
        alarm_2_mask_1: a2m1,
        alarm_2_mask_2: a2m2,
        alarm_2_mask_3: a2m3,
        day: day,
        hours: hours,
        minutes: minutes
      }) do
    minutes = BCD.from_integer(minutes)
    hours = BCD.from_integer(hours)
    day = BCD.from_integer(day)
    bin = <<a2m1::1, minutes::7, a2m2::1, hours::7, a2m3::1, day::7>>
    {:ok, bin}
  end

  def encode(_), do: {:error, :invalid}
end
