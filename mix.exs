defmodule OXR.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.strip

  def project do
    [app: :oxr,
     version: @version,
     elixir: "~> 1.2.3",
     description: "A thin API wrapper for Open Exchange Rates (https://openexchangerates.org)",
     escript: escript,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  defp escript do
    [main_module: OXR.CLI]
	end
	
  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:poison, ">= 2.1"},
     {:httpoison, ">= 0.8.2"}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*",  "LICENSE*", "VERSION"],
     maintainers: ["Mark Silvis"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/marksilvis/oxr-elixir"}]
  end
end
