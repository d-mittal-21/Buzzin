defmodule Buzzin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BuzzinWeb.Telemetry,
      Buzzin.Repo,
      {DNSCluster, query: Application.get_env(:buzzin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Buzzin.PubSub},
      {Task, fn -> Buzzin.AI.LLM.start_link() end},
      # Start a worker by calling: Buzzin.Worker.start_link(arg)
      # {Buzzin.Worker, arg},
      # Start to serve requests, typically the last entry
      BuzzinWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Buzzin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BuzzinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
