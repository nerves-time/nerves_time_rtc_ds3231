# NervesTime.RTC.DS3231

[![Hex version](https://img.shields.io/hexpm/v/nerves_time_rtc_ds3231.svg "Hex version")](https://hex.pm/packages/nerves_time_rtc_ds3231)
[![API docs](https://img.shields.io/hexpm/v/nerves_time_rtc_ds3231.svg?label=hexdocs "API docs")](https://hexdocs.pm/nerves_time_rtc_ds3231/NervesTime.RTC.DS3231.html)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/nerves-time/nerves_time_rtc_ds3231/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/nerves-time/nerves_time_rtc_ds3231/tree/main)
[![REUSE status](https://api.reuse.software/badge/github.com/nerves-time/nerves_time_rtc_ds3231)](https://api.reuse.software/info/github.com/nerves-time/nerves_time_rtc_ds3231)

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

It's possible to override the default I2C bus and address via options:

```elixir
config :nerves_time, rtc: {NervesTime.RTC.DS3231, [bus_name: "i2c-2", address:
0x69]}
```

Check the logs for error messages if the RTC doesn't appear to work.
