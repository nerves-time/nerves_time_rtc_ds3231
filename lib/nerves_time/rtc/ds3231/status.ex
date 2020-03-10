defmodule NervesTime.RTC.DS3231.Status do
  @moduledoc false

  @typedoc "The DS3231 status registers are a 1-byte binary."
  @type registers :: <<_::8>>

  @doc """
  Return a list of commands for reading the Status register
  """
  def reads() do
    # Register 0x0f
    [{:write_read, <<0x0F>>, 1}]
  end

  @spec encode(map()) :: {:ok, registers()}
  def encode(%{
        osc_stop_flag: osc_stop_flag,
        busy: busy,
        ena_32khz_out: ena_32khz_out,
        alarm_2_flag: alarm_2_flag,
        alarm_1_flag: alarm_1_flag
      }) do
    bin =
      <<osc_stop_flag::size(1), 0::size(3), ena_32khz_out::size(1), busy::size(1),
        alarm_2_flag::size(1), alarm_1_flag::size(1)>>

    {:ok, bin}
  end

  @spec decode(registers()) :: {:ok, map()} | {:error, any()}
  def decode(
        <<osc_stop_flag::size(1), _::size(3), ena_32khz_out::size(1), busy::size(1),
          alarm_2_flag::size(1), alarm_1_flag::size(1)>>
      ) do
    data = %{
      osc_stop_flag: osc_stop_flag,
      busy: busy,
      ena_32khz_out: ena_32khz_out,
      alarm_2_flag: alarm_2_flag,
      alarm_1_flag: alarm_1_flag
    }

    {:ok, data}
  end

  def decode(_other), do: {:error, :invalid}
end
