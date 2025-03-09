# SPDX-FileCopyrightText: 2020 Daniel Spofford
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule NervesTime.RTC.DS3231.TemperatureTest do
  use ExUnit.Case
  alias NervesTime.RTC.DS3231.Temperature

  test "decode/1 and encode/1" do
    data = %{celsius: 25.25}
    bin = <<0b0001_1001>> <> <<0b0100_0000>>
    assert {:ok, data} == Temperature.decode(bin)
  end
end
