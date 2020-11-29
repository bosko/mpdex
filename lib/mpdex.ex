defmodule Mpdex do
  use GenServer

  def start_link(host: host, port: port, name: name) do
    GenServer.start_link(__MODULE__, %{host: host, port: port}, name: name)
  end

  def start_link(host: host, port: port) do
    GenServer.start_link(__MODULE__, %{host: host, port: port}, name: __MODULE__)
  end

  @doc """
  Client accepts following options:

    * `:host` - IP address on which MPD is
    * `:port` - port number on which MPD listens

  and stores them in the application environment so socket client can
  later fetch those settings in order to communicate with MPD.

  ## Examples

    GenServer.start_link(Mpdex.MpdClient, %{host: "127.0.0.1", port: 6600})

  """
  @impl true
  def init(%{host: host, port: port}) do
    Application.put_env(:mpdex, :host, host)
    Application.put_env(:mpdex, :port, port)

    case connect(host, port) do
      {:ok, socket, version} ->
        :inet.setopts(socket, active: true)
        :gen_tcp.send(socket, "idle\n")

        {:ok,
         %{
           status: :connected,
           host: host,
           port: port,
           socket: socket,
           mpd_version: version,
           clients: []
         }}

      {:error, error} ->
        {:ok, %{status: :disconnected, host: host, port: port, socket: nil, error: error}}
    end
  end

  @doc """
  Gets the list of play lists.
  """
  def list(mpd) do
    GenServer.call(mpd, :playlists)
  end

  @doc """
  Gets the content of the list.
  """
  def get(mpd, list_name) do
    GenServer.call(mpd, {:list, list_name})
  end

  @doc """
  Loads the list content into the queue.
  """
  def load(mpd, list_name) do
    GenServer.call(mpd, {:load, list_name})
  end

  @doc """
  Adds URI the list. List will be created if it does not exist.
  """
  def add_to_list(mpd, list_name, uri) do
    GenServer.call(mpd, {:add_to_list, list_name, uri})
  end

  @doc """
  Clears the play list.
  """
  def clear_list(mpd, list_name) do
    GenServer.call(mpd, {:clear_list, list_name})
  end

  @doc """
  Deletes song at position from the play list.
  """
  def delete_song_at(mpd, list_name, position) do
    GenServer.call(mpd, {:delete_at, list_name, position})
  end

  @doc """
  Moves song from the position from to the position to with the play
  list.
  """
  def move_song(mpd, list_name, from, to) do
    GenServer.call(mpd, {:move_song, list_name, from, to})
  end

  @doc """
  Save the current queue to the new list.
  """
  def save_queue_to_list(mpd, list_name) do
    GenServer.call(mpd, {:save_queue_to_list, list_name})
  end

  @doc """
  Renames the list
  """
  def rename(mpd, list_name, new_name) do
    GenServer.call(mpd, {:rename_list, list_name, new_name})
  end

  @doc """
  Deletes list
  """
  def delete(mpd, list_name) do
    GenServer.call(mpd, {:delete_list, list_name})
  end

  @doc "Displays content of the queue"
  def queue(mpd) do
    GenServer.call(mpd, :queue)
  end

  @doc """
  Adds URI to the queue. If URI is directory it will be added
  recursively. Otherwise single file or URL is added.
  """
  def add_to_queue(mpd, uri) do
    GenServer.call(mpd, {:add_to_queue, uri})
  end

  @doc "Clears the queue"
  def clear(mpd) do
    GenServer.call(mpd, :clear_queue)
  end

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
  def remove_song(mpd, options) do
    GenServer.call(mpd, {:remove_from_queue, options})
  end

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
  def move_song(mpd, options) do
    GenServer.call(mpd, {:move_song, options})
  end

  @doc """
  Shuffles queue.

  It accepts the following options:

    * `:start` - start of range to be shuffled
    * `:end` - end of range to be shuffled

  Without options shuffles entire queue.
  """
  def shuffle_queue(mpd, options) do
    GenServer.call(mpd, {:shuffle, options})
  end

  @doc "Returns statistics."
  def statistics(mpd) do
    GenServer.call(mpd, :statistics)
  end

  @doc "Returns current playback status."
  @spec status(any()) :: map()
  def status(mpd) do
    GenServer.call(mpd, :status)
  end

  @doc "Sets crossfading between songs."
  def crossfade(mpd, seconds) do
    GenServer.call(mpd, {:crossface, seconds})
  end

  @doc "Plays next song in the queue."
  def next(mpd) do
    GenServer.call(mpd, :next)
  end

  @doc "Pauses playback."
  def pause(mpd) do
    GenServer.call(mpd, :pause)
  end

  @doc "Resumes playback."
  def resume(mpd) do
    GenServer.call(mpd, :resume)
  end

  @doc """
  Begins playing the playlist at song position or with song ID.

  iex> Mpdex.play(:position, 2)
  iex> Mpdex.play(:id, 23)
  """
  def play(mpd, what, val) do
    GenServer.call(mpd, {:play, what, val})
  end

  @doc "Plays previous song in the queue."
  def previous(mpd) do
    GenServer.call(mpd, :previous)
  end

  @doc "Turns random off."
  def random_off(mpd) do
    GenServer.call(mpd, :random_off)
  end

  @doc "Turns random on."
  def random_on(mpd) do
    GenServer.call(mpd, :random_on)
  end

  @doc "Turns repeat off."
  def repeat_off(mpd) do
    GenServer.call(mpd, :repeat_off)
  end

  @doc "Turns repeat on."
  def repeat_on(mpd) do
    GenServer.call(mpd, :repeat_on)
  end

  @doc """
  Seeks current song to the position time (in seconds; fractions
  allowed).
  """
  def seek(mpd, time) do
    GenServer.call(mpd, {:seek, time})
  end

  @doc """
  Seeks forward current song to the position time (in seconds;
  fractions allowed) relative to current position.
  """
  def forward(mpd, time) do
    GenServer.call(mpd, {:forward, time})
  end

  @doc """
  Seeks backward current song to the position time (in seconds;
  fractions allowed) relative to current position.
  """
  def backward(mpd, time) do
    GenServer.call(mpd, {:backward, time})
  end

  @doc "Stops playing"
  def stop(mpd) do
    GenServer.call(mpd, :stop)
  end

  @doc "Sets playback volume (from 0 to 100)"
  def volume(mpd, vol) do
    GenServer.call(mpd, {:volume, vol})
  end

  @impl true
  def handle_call(mpd_cmd, _from, state) do
    res =
      case mpd_cmd do
        :playlists ->
          Mpdex.Playlists.list()

        {:list, list_name} ->
          Mpdex.Playlists.get(list_name)

        {:load, list_name} ->
          Mpdex.Playlists.load(list_name)

        {:add_to_list, list, uri} ->
          Mpdex.Playlists.add_to_list(list, uri)

        {:clear_list, list_name} ->
          Mpdex.Playlists.clear(list_name)

        {:delete_at, list_name, position} ->
          Mpdex.Playlists.delete_song_at(list_name, position)

        {:move_song, list_name, from, to} ->
          Mpdex.Playlists.move_song(list_name, from, to)

        {:save_queue_to_list, list_name} ->
          Mpdex.Playlists.save_queue_to_list(list_name)

        {:rename_list, list_name, new_name} ->
          Mpdex.Playlists.rename(list_name, new_name)

        {:delete_list, list_name} ->
          Mpdex.Playlists.delete(list_name)

        :queue ->
          Mpdex.Queue.list()

        {:add_to_queue, uri} ->
          Mpdex.Queue.add(uri)

        :clear_queue ->
          Mpdex.Queue.clear()

        {:remove_from_queue, options} ->
          Mpdex.Queue.delete(options)

        {:move_song, options} ->
          Mpdex.Queue.move(options)

        {:shuffle, options} ->
          Mpdex.Queue.shuffle(options)

        :statistics ->
          Mpdex.Status.statistics()

        :status ->
          Mpdex.Status.status()

        {:crossfade, seconds} ->
          Mpdex.Playback.crossfade(seconds)

        :next ->
          Mpdex.Playback.next()

        :pause ->
          Mpdex.Playback.pause()

        :resume ->
          Mpdex.Playback.resume()

        {:play, what, val} ->
          Mpdex.Playback.play(what, val)

        :previous ->
          Mpdex.Playback.previous()

        :random_off ->
          Mpdex.Playback.random_off()

        :random_on ->
          Mpdex.Playback.random_on()

        :repeat_off ->
          Mpdex.Playback.repeat_off()

        :repeat_on ->
          Mpdex.Playback.repeat_on()

        {:seek, time} ->
          Mpdex.Playback.seek(time)

        {:forward, time} ->
          Mpdex.Playback.forward(time)

        {:backward, time} ->
          Mpdex.Playback.backward(time)

        :stop ->
          Mpdex.Playback.stop()

        {:volume, volume} ->
          Mpdex.Playback.volume(volume)
      end

    {:reply, res, state}
  end

  @impl true
  def handle_info({:tcp, socket, data}, state) do
    :binary.list_to_bin(data)
    |> String.split("\n")
    |> Enum.reduce([], fn chg_info, acc ->
      case chg_info do
        "changed: mixer" ->
          if false == Enum.member?(acc, :status) do
            [:status | acc]
          else
            acc
          end

        "changed: player" ->
          if false == Enum.member?(acc, :status) do
            [:status | acc]
          else
            acc
          end

        "changed: playlist" ->
          if false == Enum.member?(acc, :queue) do
            [:queue | acc]
          else
            acc
          end

        "OK" ->
          acc

        _other ->
          acc
      end
    end)
    |> Enum.each(fn what ->
      case what do
        :status ->
          status = Mpdex.Status.status()
          Enum.each(state.clients, fn client -> send(client, {:status, status}) end)

        :queue ->
          queue = Mpdex.Queue.list()
          Enum.each(state.clients, fn client -> send(client, {:queue, queue}) end)
      end
    end)

    :gen_tcp.send(socket, "idle\n")

    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, _socket}, state) do
    state =
      case connect(state.host, state.port) do
        {:ok, socket, _version} ->
          :inet.setopts(socket, active: true)
          :gen_tcp.send(socket, "idle\n")

          Map.put(state, :socket, socket)

        {:error, error} ->
          Map.merge(state, %{
            status: :disconnected,
            socket: nil,
            error: error
          })
      end

    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_error, _socket, _reason}, state) do
    {:noreply, state}
  end

  defp connect(host, port) when is_binary(host) and is_integer(port) do
    with {:ok, socket} <- :gen_tcp.connect(String.to_charlist(host), port, active: false),
         {:ok, resp} <- :gen_tcp.recv(socket, 0) do
      case to_string(resp) do
        <<"OK MPD ", version::binary>> ->
          {:ok, socket, String.trim(version)}

        _ ->
          {:error, nil}
      end
    else
      err -> {:error, err}
    end
  end
end
