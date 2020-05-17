defmodule Mpdex.Queue do
  @moduledoc """
  Module for manipulating songs queue.
  """

  def list do
    case client().send("playlistinfo") do
      {:ok, raw_queue} ->
        Mpdex.Parser.parse_play_list(raw_queue)

      {:error, error} ->
        {:error, error}
    end
  end

  def add(uri) do
    client().send("add \"#{uri}\"")
  end

  def clear do
    client().send("clear")
  end

  def delete(options) when is_list(options) do
    start_pos = Keyword.get(options, :start, nil)
    end_pos = Keyword.get(options, :end, nil)

    case {start_pos, end_pos} do
      {first, second} when is_integer(first) and is_integer(second) ->
        client().send("delete #{first}:#{second}")

      {first, nil} when is_integer(first) ->
        client().send("delete #{first}")

      _ ->
        {:error, "Invalid arguments for 'delete' command"}
    end
  end

  def move(options) when is_list(options) do
    start_pos = Keyword.get(options, :start, nil)
    end_pos = Keyword.get(options, :end, nil)
    to = Keyword.get(options, :to, nil)

    case {start_pos, end_pos, to} do
      {s, e, t} when is_integer(s) and is_integer(e) and is_integer(t) ->
        client().send("move #{s}:#{e} #{t}")

      {s, _, t} when is_integer(s) and is_integer(t) ->
        client().send("move #{s} #{t}")
    end
  end

  def shuffle(options) when is_list(options) do
    start_pos = Keyword.get(options, :start, nil)
    end_pos = Keyword.get(options, :end, nil)

    case {start_pos, end_pos} do
      {first, second} when is_integer(first) and is_integer(second) ->
        client().send("shuffle #{first}:#{second}")

      _ ->
        client().send("shuffle")
    end
  end

  defp client() do
    Application.get_env(:mpdex, :mpd_client)
  end
end
