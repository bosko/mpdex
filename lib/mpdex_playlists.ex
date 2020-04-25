defmodule Mpdex.Playlists do
  @moduledoc """
  Client for MPD (Music Player Daemon)
  """

  def list(host, port) do
    case Mpdex.Client.send("listplaylists", [host: host, port: port]) do
      {:ok, raw_lists} ->
        raw_lists
        |> String.split("\n")
        |> Enum.chunk_every(2)
        |> Enum.reduce([], fn(entry, acc) ->
        case entry do
          [<<"playlist: ", list::binary>>, <<"Last-Modified: ", modified::binary>>] ->
            [[{:playlist, list}, {:last_modified, modified}] | acc]

          _ ->
            acc
        end
        end)
        |> Enum.reverse()

      _ ->
        []
    end
  end

  def get(host, port, name) do
    case Mpdex.Client.send("listplaylistinfo #{name}", [host: host, port: port]) do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.chunk_every(3)
        |> Enum.reduce([], fn(entry, acc) ->
          case entry do
            [<<"file: ", file::binary>>, <<"Name: ", name::binary>>, <<"Time: ", time::binary>>] ->
              [[{:file, file}, {:name, name}, {:time, time}] | acc]

            [<<"file: ", file::binary>>, <<"Last-Modified: ", modified::binary>>, <<"Time: ", time::binary>>] ->
              [[{:file, file}, {:modified, modified}, {:time, time}] | acc]

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
