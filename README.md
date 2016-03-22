# OXR

A light API wrapper for [Open Exchange Rates](https://openexchangerates.org)

## Installation
  First, add OXR to your list of dependencies in `mix.exs`:

        def deps do
          [{:oxr, "~> 0.2.0"}]
        end

  Second, ensure OXR is started before your application:

        def application do
          [applications: [:oxr]]
        end
