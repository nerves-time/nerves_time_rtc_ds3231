defmodule NervesTime.RTC.DS3231.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/nerves-time/nerves_time_rtc_ds3231"

  def project do
    [
      app: :nerves_time_rtc_ds3231,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs(),
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "NervesTime.RTC implementation for Maxim Integrated DS3231 Real-Time Clock"
  end

  defp package do
    %{
      files: [
        "lib",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps do
    [
      {:circuits_i2c, "~> 0.3.6"},
      {:nerves_time, "~> 0.4.0"},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end

  def docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
