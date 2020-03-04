defmodule NervesTime.RTC.DS3231.Status do
  @moduledoc false

  @doc """
  Return a list of commands for reading the Status register
  """
  def reads() do
    # Register 0x0f
    [{:write_read, <<0x0f>>, 1}]
  end

  @spec decode(<<_::8>>) :: {:ok, map()} | {:error, any()}
  def decode(
        <<osc_stop_flag::integer-1, _::integer-3, ena_32khz_out::integer-1, busy::integer-1,
          alarm_2_flag::integer-1, alarm_1_flag::integer-1>>
      ) do
    {:ok,
      %{
        osc_stop_flag: osc_stop_flag,
        busy: busy,
        ena_32khz_out: ena_32khz_out,
        alarm_2_flag: alarm_2_flag,
        alarm_1_flag: alarm_1_flag
      }}
  end

  def decode(_other), do: {:error, :invalid}
end
