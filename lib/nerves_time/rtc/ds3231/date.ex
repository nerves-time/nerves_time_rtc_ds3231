defmodule NervesTime.RTC.DS3231.Date do
  @moduledoc false

  alias NervesTime.RealTimeClock.BCD

  @doc """
  Return a list of commands for reading and writing the time-date registers
  """
  def reads() do
    # Register 0x00 to 0x06
    [{:write_read, <<0x0>>, 7}]
  end

  @doc """
  Decode register values into a date

  This only returns years between 2000 and 2099.
  """
  @spec decode(<<_::56>>) :: {:ok, NaiveDateTime.t()} | {:error, any()}
  def decode(<<seconds_bcd, minutes_bcd, hours24_bcd, _day, date_bcd, month_bcd, year_bcd>>) do
    {:ok,
     %NaiveDateTime{
       microsecond: {0, 0},
       second: BCD.to_integer(seconds_bcd),
       minute: BCD.to_integer(minutes_bcd),
       hour: BCD.to_integer(hours24_bcd),
       day: BCD.to_integer(date_bcd),
       month: BCD.to_integer(month_bcd),
       year: 2000 + BCD.to_integer(year_bcd)
     }}
  end

  def decode(_other), do: {:error, :invalid}

  @doc """
  Encode the specified date to register values.

  Only dates between 2001 and 2099 are supported. This avoids the need to deal
  with the leap year special case for 2000. That would involve setting the
  century bit and that seems like a pointless complexity for a date that has come and gone.
  """
  @spec encode(NaiveDateTime.t()) :: {:ok, <<_::56>>} | {:error, any()}
  def encode(%NaiveDateTime{year: year} = date_time) when year > 2000 and year < 2100 do
    {microseconds, _precision} = date_time.microsecond
    seconds_bcd = BCD.from_integer(round(date_time.second + microseconds / 1_000_000))
    minutes_bcd = BCD.from_integer(date_time.minute)
    hours24_bcd = BCD.from_integer(date_time.hour)
    day_bcd = BCD.from_integer(Calendar.ISO.day_of_week(year, date_time.month, date_time.day))
    date_bcd = BCD.from_integer(date_time.day)
    month_bcd = BCD.from_integer(date_time.month)
    year_bcd = BCD.from_integer(year - 2000)

    {:ok,
     <<
       seconds_bcd,
       minutes_bcd,
       hours24_bcd,
       day_bcd,
       date_bcd,
       month_bcd,
       year_bcd
     >>}
  end

  def encode(_invalid_date) do
    {:error, :invalid_date}
  end
end
