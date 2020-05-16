defmodule Mpdex.Playlists do
  @moduledoc """
  Client for MPD (Music Player Daemon)
  """

  def list do
    case client().send("listplaylists") do
      {:ok, raw_lists} ->
        raw_lists
        |> String.split("\n")
        |> Enum.chunk_every(2)
        |> Enum.reduce([], fn entry, acc ->
          case entry do
            [<<"playlist: ", list::binary>>, <<"Last-Modified: ", modified::binary>>] ->
              modified =
                case DateTime.from_iso8601(modified) do
                  {:ok, date_time, _} ->
                    date_time

                  _ ->
                    nil
                end

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

  def get(list_name) do
    case client().send("listplaylistinfo #{list_name}") do
      {:ok, content} ->
        Mpdex.Parser.parse_play_list(content)

      _ ->
        []
    end
  end

  def load(list_name) do
    send_simple_cmd("load #{list_name}")
  end

  def add_to_list(list_name, uri) do
    send_simple_cmd("playlistadd #{list_name} #{uri}")
  end

  def clear(list_name) do
    send_simple_cmd("playlistclear #{list_name}")
  end

  def delete_song_at(list_name, position) do
    send_simple_cmd("playlistdelete #{list_name} #{position}")
  end

  def move_song(list_name, from, to) do
    send_simple_cmd("playlistmove #{list_name} #{from} #{to}")
  end

  def save_queue_to_list(list_name) do
    send_simple_cmd("save #{list_name}")
  end

  def rename(list_name, new_name) do
    send_simple_cmd("rename #{list_name} #{new_name}")
  end

  def delete(list_name) do
    send_simple_cmd("rm #{list_name}")
  end

  defp send_simple_cmd(cmd) do
    case client().send(cmd) do
      {:ok, res} ->
        {:ok, res}

      {:error, err} ->
        {:error, err}
    end
  end

  defp client() do
    Application.get_env(:mpdex, :mpd_client)
  end
end
