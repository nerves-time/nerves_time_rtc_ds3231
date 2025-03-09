# SPDX-FileCopyrightText: 2020 Daniel Spofford
# SPDX-FileCopyrightText: 2020 Frank Hunleth
# SPDX-FileCopyrightText: 2020 John Simmonds
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule NervesTime.RTC.DS3231.Control do
  @moduledoc false

  @typedoc "The DS3231 control registers are a 1-byte binary."
  @type registers :: <<_::8>>

  @doc """
  Return a list of commands for reading the Control register
  """
  def reads() do
    # Register 0x0e
    [{:write_read, <<0x0E>>, 1}]
  end

  @spec decode(registers()) :: {:ok, map()} | {:error, any()}
  def decode(
        <<osc_enable::1, bbsqw::1, conv_temp::1, rate_sel_1::1, rate_sel_0::1,
          interrupt_control::1, alarm_2_int_ena::1, alarm_1_int_ena::1>>
      ) do
    data = %{
      alarm_1_int_ena: alarm_1_int_ena,
      alarm_2_int_ena: alarm_2_int_ena,
      bbsqw: bbsqw,
      conv_temp: conv_temp,
      interrupt_control: interrupt_control,
      rate_sel_0: rate_sel_0,
      rate_sel_1: rate_sel_1,
      osc_enable_: osc_enable
    }

    {:ok, data}
  end

  def decode(_other), do: {:error, :invalid}

  @spec encode(map()) :: {:ok, registers()} | {:error, :invalid}
  def encode(%{
        alarm_1_int_ena: alarm_1_int_ena,
        alarm_2_int_ena: alarm_2_int_ena,
        bbsqw: bbsqw,
        conv_temp: conv_temp,
        interrupt_control: interrupt_control,
        rate_sel_0: rate_sel_0,
        rate_sel_1: rate_sel_1,
        osc_enable_: osc_enable
      }) do
    bin =
      <<osc_enable::1, bbsqw::1, conv_temp::1, rate_sel_1::1, rate_sel_0::1, interrupt_control::1,
        alarm_2_int_ena::1, alarm_1_int_ena::1>>

    {:ok, bin}
  end

  def encode(_), do: {:error, :invalid}
end
