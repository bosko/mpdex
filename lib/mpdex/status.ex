defmodule Mpdex.Status do
  def idle(subsystem) do
    client().send("idle #{subsystem}")
  end

  def statistics() do
    case client().send("stats") do
      {:ok, raw_stats} ->
        Mpdex.Parser.parse_key_value(raw_stats)

      _ ->
        []
    end
  end

  def status() do
    case client().send("status") do
      {:ok, raw_status} ->
        Mpdex.Parser.parse_key_value(raw_status)

      _ ->
        []
    end
  end

  defp client() do
    Application.get_env(:mpdex, :mpd_client)
  end
end
