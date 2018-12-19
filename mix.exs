defmodule ProviderSuite.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:edeliver, "~> 1.4.4"},
      {:distillery, "~> 1.4"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.setup-no-seed": ["ecto.create", "ecto.migrate"],
      "ecto.seed": ["run apps/data/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"],
      "ecto.reset-seed": ["ecto.reset", "ecto.seed"]
    ]
  end
end
