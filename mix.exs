defmodule WebSlinger.Mixfile do
  use Mix.Project

  #######
  # API #
  #######

  def application() do
    [
      extra_applications: extra_applications(),
    ]
  end

  def project() do
    [
      app:              app(),
      build_embedded:   build_embedded(),
      deps:             deps(),
      elixir:           elixir(),
      start_permanent:  start_permanent(),
      version:          version(),
    ]
  end

  ###########
  # Private #
  ###########

  defp app() do
    :web_slinger
  end

  defp build_embedded() do
     Mix.env == :prod
  end

  defp deps() do
    [
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev},
    ]
  end

  defp elixir() do
    "~> 1.4"
  end

  defp extra_applications() do
    extra_applications(Mix.env()) ++ [
      :logger,
    ]
  end

  defp extra_applications(:dev) do
    [
      :mix,
    ]
  end

  defp extra_applications(_) do
    []
  end

  defp start_permanent() do
    Mix.env == :prod
  end

  defp version() do
    "0.1.0"
  end
end
