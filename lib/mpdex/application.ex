defmodule Mpdex.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Registry, [keys: :duplicate, name: Mpdex.Registry]},
    ]

    opts = [strategy: :one_for_one, name: Mpdex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
