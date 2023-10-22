defmodule NervesTime.RTC.DS3231.MixProject do
  use Mix.Project

  @version "0.1.2"
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
        flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs]
      ],
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
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
      {:circuits_i2c, "~> 1.0 or ~> 0.3.6 or ~> 2.0"},
      {:nerves_time, "~> 0.4.0"},
      {:ex_doc, "~> 0.19", only: :docs, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
