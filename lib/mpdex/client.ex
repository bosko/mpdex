defmodule Mpdex.Client do
  @moduledoc """
  Specifies client API required from MPD client
  """

  @doc "Method for sending command to MPD server"
  @callback send(cmd :: binary) :: {:ok, :any} | {:error, atom() | binary() | map()}
end
