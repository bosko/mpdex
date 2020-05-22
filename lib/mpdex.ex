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

  ## Examples

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
  defdelegate clear_list(list_name), to: Mpdex.Playlists, as: :clear

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

  @doc "Displays content of the queue"
  defdelegate queue, to: Mpdex.Queue, as: :list

  @doc """
  Adds URI to the queue. If URI is directory it will be added
  recursively. Otherwise single file or URL is added.
  """
  defdelegate add_to_queue(uri), to: Mpdex.Queue, as: :add

  @doc "Clears the queue"
  defdelegate clear, to: Mpdex.Queue

  @doc """
  Deletes song or range of songs from the queue.

  It accepts following options:

    * `:start` - start position
    * `:end` - end position (exclusive)

  If both arguments are given all songs in the range will be
  removed, otherwise removes song on the position `:start`.

  ## Examples

    iex> Mpdex.remove_song(start: 1) # deletes song on position 1
    {:ok, "OK\n}

    iex> Mpdex.remove_song(start: 0, end: 3) # deletes songs 0, 1 and 2
    {:ok, "OK\n}

  """
  defdelegate remove_song(options), to: Mpdex.Queue, as: :delete

  @doc """
  Moves song or range of songs to the given position.

  It accepts the following options:

    * `:start` - start position
    * `:end` - end position (song on `end` position is excluded)
    * `:to` - position to which songs will be moved

  If both arguments are given all songs in the range will be
  moved, otherwise moves song on the position `:start`.

  ## Examples

    iex> Mpdex.move_song(start: 1, to: 0)
    {:ok, "OK\n}

    iex> Mpdex.move_song(start: 0, end: 3, to: 5)
    {:ok, "OK\n}

  """
  defdelegate move_song(options), to: Mpdex.Queue, as: :move

  @doc """
  Shuffles queue.

  It accepts the following options:

    * `:start` - start of range to be shuffled
    * `:end` - end of range to be shuffled

  Without options shuffles entire queue.
  """
  defdelegate shuffle_queue(options), to: Mpdex.Queue, as: :shuffle

  defdelegate idle(subsystem), to: Mpdex.Status

  @doc "Returns statistics."
  defdelegate statistics, to: Mpdex.Status

  @doc "Returns current playback status."
  defdelegate status, to: Mpdex.Status

  @doc "Sets crossfading between songs."
  defdelegate crossfade(seconds), to: Mpdex.Playback

  @doc "Plays next song in the queue."
  defdelegate next, to: Mpdex.Playback

  @doc "Pauses playback."
  defdelegate pause, to: Mpdex.Playback

  @doc "Resumes playback."
  defdelegate resume, to: Mpdex.Playback

  @doc """
  Begins playing the playlist at song position or with song ID.

  iex> Mpdex.play(:position, 2)
  iex> Mpdex.play(:id, 23)
  """
  defdelegate play(what, val), to: Mpdex.Playback

  @doc "Plays previous song in the queue."
  defdelegate previous, to: Mpdex.Playback

  @doc "Turns random off."
  defdelegate random_off, to: Mpdex.Playback

  @doc "Turns random on."
  defdelegate random_on, to: Mpdex.Playback

  @doc "Turns repeat off."
  defdelegate repeat_off, to: Mpdex.Playback

  @doc "Turns repeat on."
  defdelegate repeat_on, to: Mpdex.Playback

  @doc """
  Seeks current song to the position time (in seconds; fractions
  allowed).
  """
  defdelegate seek(time), to: Mpdex.Playback

  @doc """
  Seeks forward current song to the position time (in seconds;
  fractions allowed) relative to current position.
  """
  defdelegate forward(time), to: Mpdex.Playback

  @doc """
  Seeks backward current song to the position time (in seconds;
  fractions allowed) relative to current position.
  """
  defdelegate backward(time), to: Mpdex.Playback

  @doc "Stops playing"
  defdelegate stop, to: Mpdex.Playback

  @doc "Sets playback volume (from 0 to 100)"
  defdelegate volume(vol), to: Mpdex.Playback
end
