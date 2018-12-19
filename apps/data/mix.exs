defmodule Data.Mixfile do
  use Mix.Project

  def project do
    [
      app: :data,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Data.Application, []},
      extra_applications: [
        :logger,
        :ecto,
        :postgrex,
        :poison,
        :arc,
        :arc_ecto,
        :geo,
        :csv
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.2.1"},
      {:poison, "~> 3.1"},
      {:geo, "~> 2.0"},
      {:geo_postgis, "~> 1.0"},
      {:ex_machina, "~> 1.0"},
      {:comeonin, "~> 3.0"},
      {:arc, "~> 0.8.0"},
      {:arc_ecto, "~> 0.7.0"},
      {:hackney, "~> 1.6"},
      {:ueberauth, "~> 0.4"},
      {:sweet_xml, "~> 0.6"},
      {:timex, "~> 3.0"},
      {:cowboy, "~> 1.1.2"},
      {:cowlib, "~> 1.0.2"},
      {:mime, "~> 1.1.0"},
      {:plug, "~> 1.4.3"},
      {:ranch, "~> 1.3.2"},
      {:ex_aws, "~> 1.1"},
      {:elixlsx, "~> 0.4.0"},
      {:csv, "~> 2.0.0"}
    ]
  end
end
