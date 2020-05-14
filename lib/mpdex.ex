defmodule Mpdex do
  def configure(options \\ []) do
    Application.put_env(:mpdex, :host, Keyword.get(options, :host, "localhost"))
    Application.put_env(:mpdex, :port, Keyword.get(options, :port, 6600))
  end
end
