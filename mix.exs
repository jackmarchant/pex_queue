defmodule PriorityQueue.MixProject do
  use Mix.Project

  def project do
    [
      app: :priority_queue,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A simple FIFO Queue, with optional prioritisation",
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    ]
  end

  defp package do
    [
      maintainers: ["Jack Marchant"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jackmarchant/priority_queue"}
    ]
  end
end
