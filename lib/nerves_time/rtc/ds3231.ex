defmodule NervesTime.RTC.DS3231 do
  @moduledoc """
  DS3231 RTC implementation for NervesTime

  To configure NervesTime to use this module, update the `:nerves_time` application
  environment like this:

  ```elixir
  config :nerves_time, rtc: NervesTime.RTC.DS3231
  ```

  To override the default I2C bus, I2C address, or centuries one may:

  ```elixir
  rtc_opts = [
    address: 0x68,
    bus_name: "i2c-1",
    century: 2000
  ]
  config :nerves_time, rtc: {NervesTime.RTC.DS3231, rtc_opts}
  ```

  The `:century` option indicates to this library what century to choose when the DS3231's century
  bit is set to logic `0`. When the bit is logic `1` the cetury will be the value of `:century`
  plus 100. Internally the DS3231 will toggle its century bit when its years counter rolls over.

  Check the logs for error messages if the RTC doesn't appear to work.

  See https://datasheets.maximintegrated.com/en/ds/DS3231.pdf for implementation details.
  """

  @behaviour NervesTime.RealTimeClock

  require Logger

  alias Circuits.I2C
  alias NervesTime.RTC.DS3231.{Date, Status}

  @default_address 0x68
  @default_bus_name "i2c-1"
  @default_century_0 2000

  @typedoc """
  A number representing a century.

  For example, 2000 or 2100.
  """
  @type century() :: integer()

  @typedoc "This type represents the many registers whose value is a single bit."
  @type flag :: 0 | 1

  @typedoc false
  @type state :: %{
          address: I2C.address(),
          bus_name: String.t(),
          century_0: I2C.address(),
          century_1: I2C.address(),
          i2c: I2C.bus()
        }

  @impl NervesTime.RealTimeClock
  def init(args) do
    address = Keyword.get(args, :address, @default_address)
    bus_name = Keyword.get(args, :bus_name, @default_bus_name)

    with {:ok, i2c} <- I2C.open(bus_name) do
      century_0 = Keyword.get(args, :century_0, @default_century_0)

      state = %{
        address: address,
        bus_name: bus_name,
        century_0: century_0,
        century_1: century_0 + 100,
        i2c: i2c
      }

      {:ok, state}
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
    with {:ok, date_registers} <- Date.encode(now, state.century_0, state.century_1),
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
         {:ok, time} <- Date.decode(registers, state.century_0, state.century_1) do
      {:ok, time, state}
    else
      any_error ->
        _ = Logger.error("DS3231 RTC not set or has an error: #{inspect(any_error)}")
        {:unset, state}
    end
  end
end
