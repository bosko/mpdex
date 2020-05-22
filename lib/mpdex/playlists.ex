defmodule Mpdex.Playlists do
  @moduledoc """
  Client for MPD (Music Player Daemon)
  """

  def list do
    case client().send("listplaylists") do
      {:ok, raw_lists} ->
        Mpdex.Parser.parse_list_of_play_lists(raw_lists)

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
    client().send("load #{list_name}")
  end

  def add_to_list(list_name, uri) do
    client().send("playlistadd #{list_name} #{uri}")
  end

  def clear(list_name) do
    client().send("playlistclear #{list_name}")
  end

  def delete_song_at(list_name, position) do
    client().send("playlistdelete #{list_name} #{position}")
  end

  def move_song(list_name, from, to) do
    client().send("playlistmove #{list_name} #{from} #{to}")
  end

  def save_queue_to_list(list_name) do
    client().send("save #{list_name}")
  end

  def rename(list_name, new_name) do
    client().send("rename #{list_name} #{new_name}")
  end

  def delete(list_name) do
    client().send("rm #{list_name}")
  end

  defp client() do
    Application.get_env(:mpdex, :mpd_client)
  end
end
