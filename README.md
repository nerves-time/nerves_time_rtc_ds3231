# NervesTime.RTC.DS3231

[![CircleCI](https://circleci.com/gh/nerves-time/nerves_time_rtc_ds3231.svg?style=svg)](https://circleci.com/gh/nerves-time/nerves_time_rtc_ds3231)
[![Hex version](https://img.shields.io/hexpm/v/nerves_time_rtc_ds3231.svg "Hex version")](https://hex.pm/packages/nerves_time_rtc_ds3231)

NervesTime.RTC implementation for popular Maxim Integrated Extremely Accurate
Real-Time Clock chip with TCXO.  [An "Oldie-but-Goodie". Dallas Semiconductor
was acquired by Maxim in 2001]

Features of the DS3231 device other than the time and date registers  [i.e.
Alarms, Interrupts, Square Wave output and Temperature measurement]  are
untouched by this plugin, and are therefore available to other user-written
Elixir apps.

The following are supported:

* [DS3231](https://datasheets.maximintegrated.com/en/ds/DS3231.pdf)

## Using

First add this project to your `mix` dependencies:

```elixir
def deps do
  [
    {:nerves_time_rtc_ds3231, "~> 0.1.0"}
  ]
end
```

And then update your `:nerves_time` configuration to point to it:

```elixir
config :nerves_time, rtc: NervesTime.RTC.DS3231
```

It's possible to override the default I2C bus, I2C address, and current `:century` via options:

```elixir
rtc_opts = [
  address: 0x68,
  bus_name: "i2c-1",
  century: 2000
]
config :nerves_time, rtc: {NervesTime.RTC.DS3231, rtc_opts}
```

The `:century` option indicates to this library what century to associate with the DS3231's
century bit set to logic `0`. Logic `1` is associated with `:century` plus 100. Internally the
DS3231 will toggle its century bit when its years counter rolls over.

Check the logs for error messages if the RTC doesn't appear to work.
