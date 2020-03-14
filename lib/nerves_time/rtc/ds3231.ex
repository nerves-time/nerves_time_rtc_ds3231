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
  alias NervesTime.RTC.DS3231.{Date, Status}

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
    with {:ok, date_registers} <- Date.encode(now),
         {:ok, status_registers} <- I2C.write_read(state.i2c, state.address, <<0x0F>>, 1),
         {:ok, status_data} <- Status.decode(status_registers),
         {:ok, status_registers} <- Status.encode(%{status_data | osc_stop_flag: 0}),
         :ok <- I2C.write(state.i2c, state.address, [0x00, date_registers]),
         :ok <- I2C.write(state.i2c, state.address, [0x0F, status_registers]) do
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

  defp rtc_available?(i2c, address) do
    case I2C.write_read(i2c, address, <<0>>, 1) do
      {:ok, <<_::8>>} -> true
      {:error, _} -> false
    end
  end
end
