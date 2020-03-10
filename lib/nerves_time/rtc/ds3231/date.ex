defmodule NervesTime.RTC.DS3231.Date do
  @moduledoc false

  alias NervesTime.{RealTimeClock.BCD, RTC.DS3231}
  require Bitwise

  @typedoc "The DS3231 date registers are a 7-byte binary."
  @type date_registers() :: <<_::56>>

  @doc """
  Return a list of commands for reading and writing the time-date registers
  """
  def reads() do
    # Register 0x00 to 0x06
    [{:write_read, <<0x0>>, 7}]
  end

  @doc """
  Decode register values into a date

  Only decodes dates `>= century_0` and `< century_1 + 100`.
  """
  @spec decode(date_registers(), DS3231.century(), DS3231.century()) ::
          {:ok, NaiveDateTime.t()} | {:error, any()}
  def decode(
        <<seconds_bcd, minutes_bcd, hours24_bcd, _day, date_bcd, century::size(1),
          month_bcd::size(7), year_bcd>>,
        century_0,
        century_1
      ) do
    century = if century == 0, do: century_0, else: century_1

    date_time = %NaiveDateTime{
      microsecond: {0, 0},
      second: BCD.to_integer(seconds_bcd),
      minute: BCD.to_integer(minutes_bcd),
      hour: BCD.to_integer(hours24_bcd),
      day: BCD.to_integer(date_bcd),
      month: BCD.to_integer(month_bcd),
      year: century + BCD.to_integer(year_bcd)
    }

    {:ok, date_time}
  end

  def decode(_, _, _), do: {:error, :invalid}

  @doc """
  Encode the specified date to register values.

  Only encodes dates `>= century_0` and `< century_1 + 100`.
  """
  @spec encode(NaiveDateTime.t(), DS3231.century(), DS3231.century()) ::
          {:ok, date_registers()} | {:error, any()}
  def encode(%NaiveDateTime{year: year} = date_time, century_0, century_1)
      when year >= century_0 and year < century_1 + 100 do
    {microseconds, _precision} = date_time.microsecond
    seconds_bcd = BCD.from_integer(round(date_time.second + microseconds / 1_000_000))
    minutes_bcd = BCD.from_integer(date_time.minute)
    hours24_bcd = BCD.from_integer(date_time.hour)
    day_bcd = BCD.from_integer(Calendar.ISO.day_of_week(year, date_time.month, date_time.day))
    date_bcd = BCD.from_integer(date_time.day)
    {century, century_mask} = resolve_century(year, century_0, century_1)
    month_bcd = Bitwise.bor(century_mask, BCD.from_integer(date_time.month))
    year_bcd = BCD.from_integer(year - century)

    bin = <<
      seconds_bcd,
      minutes_bcd,
      hours24_bcd,
      day_bcd,
      date_bcd,
      month_bcd,
      year_bcd
    >>

    {:ok, bin}
  end

  def encode(_, _, _), do: {:error, :invalid_date}

  defp resolve_century(year, century_0, century_1) when year >= century_0 and year < century_1 do
    {century_0, 0b0000_0000}
  end

  defp resolve_century(year, _, century_1)
       when year >= century_1 and year < century_1 + 100 do
    {century_1, 0b1000_0000}
  end
end
