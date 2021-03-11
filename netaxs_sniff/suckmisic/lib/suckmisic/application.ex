defmodule Suckmisic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Suckmisic.Repo,
      # Start the Telemetry supervisor
      SuckmisicWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Suckmisic.PubSub},
      # Start the Endpoint (http/https)
      SuckmisicWeb.Endpoint,
      # Start a worker by calling: Suckmisic.Worker.start_link(arg)
      # {Suckmisic.Worker, arg}
      {Suckmisic.Sync.SyncConfig, %{count: 2, timeout: 200}},
      {Suckmisic.Sync.ServerRegister, %{}},

      Suckmisic.Node.NodeSupervisor,
      {Suckmisic.Node.NodeManager, %{}},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Suckmisic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SuckmisicWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
