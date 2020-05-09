defmodule Mpdex.TestClient do
  @behaviour Mpdex.Client

  @playlists Path.expand("../fixtures/playlists", __DIR__)
  @playlists_pattern ~r/[listplaylists | listplaylistinfo | load | playlistadd | playlistclear | playlistdelete | playlistmove | save | rename | rm](.*)/

  @impl Mpdex.Client
  def send(cmd, _options) do
    cond do
      Regex.match?(@playlists_pattern, cmd) ->
        playlist_cmd(cmd)

      true ->
        {:error, "Unrecognized command"}
    end
  end

  defp playlist_cmd(cmd) do
    cond do
      cmd == "listplaylists" ->
        File.read(Path.join(@playlists, "list.txt"))

      cmd == "listplaylistinfo dummy" ->
        File.read(Path.join(@playlists, "get.txt"))

      true ->
        {:error, "Unknown playlist command"}
    end
  end
end
