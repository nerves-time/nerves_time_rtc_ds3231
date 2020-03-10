defmodule NervesTime.RTC.DS3231.Temperature do
  @moduledoc false

  @typedoc "The DS3231 temperature registers are a 2-byte binary."
  @type registers :: <<_::16>>

  @spec decode(registers()) :: {:ok, map()} | {:error, any()}
  def decode(<<sign_bit::size(1), upper::size(7), lower::size(2), _::bits>>) do
    places = if lower == 1, do: 2, else: 1
    fraction = if lower == 0, do: 0, else: Enum.reduce(1..places, lower, fn _, acc -> acc / 2 end)
    sign = if sign_bit == 1, do: -1, else: 1
    celsius = sign * (upper + fraction)
    {:ok, %{celsius: celsius}}
  end

  def decode(_other), do: {:error, :invalid}
end
