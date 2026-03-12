defmodule Oxide.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/dannote/oxide_ex"

  def project do
    [
      app: :oxide,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:mix]],
      name: "Oxide",
      description:
        "Elixir NIF bindings for Tailwind CSS Oxide — fast parallel content scanning and candidate extraction.",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Tailwind CSS" => "https://tailwindcss.com"
      },
      files:
        ~w(lib native/oxide_ex_nif/src native/oxide_ex_nif/Cargo.toml Cargo.toml Cargo.lock .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "Oxide",
      extras: ["README.md", "LICENSE"],
      source_ref: "v#{@version}"
    ]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "credo --strict",
        "ex_dna",
        "dialyzer",
        "cmd cargo fmt --manifest-path native/oxide_ex_nif/Cargo.toml -- --check",
        "cmd cargo clippy --manifest-path native/oxide_ex_nif/Cargo.toml -- -D warnings"
      ],
      ci: ["lint", "cmd MIX_ENV=test mix test"]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.36 or ~> 0.37"},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.2", only: [:dev, :test], runtime: false}
    ]
  end
end
