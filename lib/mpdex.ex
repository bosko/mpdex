defmodule Mpdex do
  @moduledoc """
  Mpdex is small library for communicating with Music Player Daemon.
  """

  @doc """
  Configures host and port to which Mpdex will connect.

  If not called or called with empty list Mpdex will work on default
  MPD settings - localhost on port 6600

  It accepts following options:

    * `:host` - IP address on which MPD is
    * `:port` - port number on which MPD listens

  # Example

    Mpdex.configure(host: "192.168.0.5", port: 6600)

  """
  def configure(options \\ []) do
    Application.put_env(:mpdex, :host, Keyword.get(options, :host, "localhost"))
    Application.put_env(:mpdex, :port, Keyword.get(options, :port, 6600))
  end

  @doc """
  Gets the list of play lists.
  """
  defdelegate list, to: Mpdex.Playlists

  @doc """
  Gets the content of the list.
  """
  defdelegate get(list_name), to: Mpdex.Playlists

  @doc """
  Loads the list content into the queue.
  """
  defdelegate load(list_name), to: Mpdex.Playlists

  @doc """
  Adds URI the list. List will be created if it does not exist.
  """
  defdelegate add_to_list(list_name, uri), to: Mpdex.Playlists

  @doc """
  Clears the play list.
  """
  defdelegate clear(list_name), to: Mpdex.Playlists

  @doc """
  Deletes song at position from the play list.
  """
  defdelegate delete_song_at(list_name, position), to: Mpdex.Playlists

  @doc """
  Moves song from the position from to the position to with the play
  list.
  """
  defdelegate move_song(list_name, from, to), to: Mpdex.Playlists

  @doc """
  Save the current queue to the new list.
  """
  defdelegate save_queue_to_list(list_name), to: Mpdex.Playlists

  @doc """
  Renames the list
  """
  defdelegate rename(list_name, new_name), to: Mpdex.Playlists

  @doc """
  Deletes list
  """
  defdelegate delete(list_name), to: Mpdex.Playlists
end
