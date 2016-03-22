# OXR

A thin API wrapper for [Open Exchange Rates](https://openexchangerates.org)

## Installation
  First, add OXR to your list of dependencies in `mix.exs`:

        def deps do
          [{:oxr, "~> 0.3.1"}]
        end

  Second, ensure OXR is started before your application:

        def application do
          [applications: [:oxr]]
        end

## CLI
  You can use the OXR cli by building an escript:

        mix escript.build

  Then using ./oxr