defmodule Mpdex.Playback do
  def crossfade(seconds) when is_integer(seconds) do
    client().send("crossfade #{seconds}")
  end

  def next do
    client().send("next")
  end

  def resume do
    client().send("pause 0")
  end

  def pause do
    client().send("pause 1")
  end

  def play(what, pos) do
    case {what, pos} do
      {:position, position} ->
        client().send("play #{position}")

      {:id, id} ->
        client().send("playid #{id}")

      _ ->
        {:error, "Invalid options"}
    end
  end

  def previous do
    client().send("previous")
  end

  def random_off do
    client().send("random 0")
  end

  def random_on do
    client().send("random 1")
  end

  def repeat_off do
    client().send("repeat 0")
  end

  def repeat_on do
    client().send("repeat 1")
  end

  def seek(time) when is_float(time) do
    client().send("seek #{time}")
  end

  def forward(time) when is_float(time) do
    client().send("seek +#{time}")
  end

  def backward(time) when is_float(time) do
    client().send("seek -#{time}")
  end

  def stop do
    client().send("stop")
  end

  def volume(vol) when is_integer(vol) and vol >= 0 and vol <= 100 do
    client().send("setvol #{vol}")
  end

  defp client() do
    Application.get_env(:mpdex, :mpd_client)
  end
end
