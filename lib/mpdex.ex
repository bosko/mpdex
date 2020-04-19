defmodule Mpdex do
  @moduledoc """
  Client for MPD (Music Player Daemon)
  """

  def playlists(host, port) do
    case Mpdex.Client.send("listplaylists", [host: host, port: port]) do
      {:ok, raw_lists} ->
        raw_lists
        |> String.split("\n")
        |> Enum.chunk_every(2)
        |> Enum.reduce([], fn(entry, acc) ->
        case entry do
          [<<"playlist: ", list::binary>>, <<"Last-Modified: ", modified::binary>>] ->
            [%{playlist: list, last_modified: modified} | acc]

          _ ->
            acc
        end
        end)
        |> Enum.reverse()

      _ ->
        []
    end
  end
end
