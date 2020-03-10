defmodule NervesTime.RTC.DS3231 do
  @moduledoc """
  DS3231 RTC implementation for NervesTime

  To configure NervesTime to use this module, update the `:nerves_time` application
  environment like this:

  ```elixir
  config :nerves_time, rtc: NervesTime.RTC.DS3231
  ```

  If not using `"i2c-1"` or the default I2C bus address, specify them like this:

  ```elixir
  config :nerves_time, rtc: {NervesTime.RTC.DS3231, [bus_name: "i2c-2", address: 0x69]}
  ```

  Check the logs for error messages if the RTC doesn't appear to work.

  See https://datasheets.maximintegrated.com/en/ds/DS3231.pdf for implementation details.
  """

  @behaviour NervesTime.RealTimeClock

  require Logger

  alias Circuits.I2C
  alias NervesTime.RTC.DS3231.{Alarm, Control, Date, Status, Temperature}

  @default_bus_name "i2c-1"
  @default_address 0x68

  @typedoc "This type represents the many registers whose value is a single bit."
  @type flag :: 0 | 1

  @typedoc false
  @type state :: %{
          i2c: I2C.bus(),
          bus_name: String.t(),
          address: I2C.address()
        }

  @impl NervesTime.RealTimeClock
  def init(args) do
    bus_name = Keyword.get(args, :bus_name, @default_bus_name)
    address = Keyword.get(args, :address, @default_address)

    with {:ok, i2c} <- I2C.open(bus_name),
         true <- rtc_available?(i2c, address) do
      {:ok, %{i2c: i2c, bus_name: bus_name, address: address}}
    else
      {:error, _} = error ->
        error

      error ->
        {:error, error}
    end
  end

  @impl NervesTime.RealTimeClock
  def terminate(_state), do: :ok

  @impl NervesTime.RealTimeClock
  def set_time(state, now) do
    with {:ok, status_data} <- get_status(state.i2c, state.address),
         :ok <- set(state.i2c, state.address, 0x0F, now, Date),
         :ok <- set_status(state.i2c, state.address, %{status_data | osc_stop_flag: 0}) do
      state
    else
      error ->
        _ = Logger.error("Error setting DS3231 RTC to #{inspect(now)}: #{inspect(error)}")
        state
    end
  end

  @impl NervesTime.RealTimeClock
  def get_time(state) do
    with {:ok, registers} <- I2C.write_read(state.i2c, state.address, <<0>>, 7),
         {:ok, time} <- Date.decode(registers) do
      {:ok, time, state}
    else
      any_error ->
        _ = Logger.error("DS3231 RTC not set or has an error: #{inspect(any_error)}")
        {:unset, state}
    end
  end

  @doc "Reads the status register."
  def get_status(i2c, address), do: get(i2c, address, 0x0F, 1, Status)

  @doc "Writes the status register."
  def set_status(i2c, address, status), do: set(i2c, address, 0x0F, status, Status)

  @doc "Reads the control register."
  def get_control(i2c, address), do: get(i2c, address, 0x0E, 1, Control)

  @doc "Writes the control register."
  def set_control(i2c, address, control), do: set(i2c, address, 0x0E, control, Control)
  @doc "Reads an alarm register."
  def get_alarm(i2c, address, 1 = _alarm_num), do: get(i2c, address, 0x07, 4, Alarm)
  def get_alarm(i2c, address, 2 = _alarm_num), do: get(i2c, address, 0x0B, 3, Alarm)

  @doc "Writes an alarm register."
  def set_alarm(i2c, address, %{seconds: _} = a1), do: set(i2c, address, 0x07, a1, Alarm)
  def set_alarm(i2c, address, a2), do: set(i2c, address, 0x0B, a2, Alarm)

  @doc "Reads the temperature register."
  def get_temperature(i2c, address), do: get(i2c, address, 0x11, 2, Temperature)

  defp set(i2c, address, offset, data, module) do
    with {:ok, bin} <- module.encode(data),
         :ok <- I2C.write(i2c, address, [offset, bin]) do
      :ok
    else
      {:error, _} = e -> e
      e -> {:error, e}
    end
  end

  defp get(i2c, address, offset, length, module) do
    with {:ok, bin} <- I2C.write_read(i2c, address, <<offset>>, length),
         {:ok, data} <- module.decode(bin) do
      {:ok, data}
    else
      {:error, _} = e -> e
      e -> {:error, e}
    end
  end

  defp rtc_available?(i2c, address) do
    case I2C.write_read(i2c, address, <<0>>, 1) do
      {:ok, <<_::8>>} -> true
      {:error, _} -> false
    end
  end
end
