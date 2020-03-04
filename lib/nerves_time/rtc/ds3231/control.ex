defmodule NervesTime.RTC.DS3231.Control do
  @moduledoc false

  @doc """
  Return a list of commands for reading the Control register
  """
  def reads() do
    # Register 0x0e
    [{:write_read, <<0x0e>>, 1}]
  end

  @spec decode(<<_::8>>) :: {:ok, map()} | {:error, any()}
  def decode(
        <<osc_enable::integer-1,
          _bbsqw::integer-1,
          _conv_temp::integer-1,
          _rate_sel_1::integer-1,
          _rate_sel_0::integer-1,
          _interrupt_control::integer-1,
          _alarm_2_int_ena::integer-1,
          _alarm_1_int_ena::integer-1>>
      ) do
    {:ok,
      %{
        osc_enable_: osc_enable
      }}
  end

  def decode(_other), do: {:error, :invalid}
end
