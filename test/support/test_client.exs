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

      cmd == "load dummy" ->
        {:ok, "OK\n"}

      cmd == "playlistadd dummy http://example.com" ->
        {:ok, "OK\n"}

      cmd == "playlistclear dummy" ->
        {:ok, "OK\n"}

      cmd == "playlistdelete dummy 1" ->
        {:ok, "OK\n"}

      cmd == "playlistmove dummy 2 1" ->
        {:ok, "OK\n"}

      cmd == "save dummy_1" ->
        {:ok, "OK\n"}

      cmd == "rename dummy old-dummy" ->
        {:ok, "OK\n"}

      cmd == "rm dummy" ->
        {:ok, "OK\n"}

      true ->
        {:error, "Unknown playlist command"}
    end
  end
end
