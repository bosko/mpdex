defmodule Mpdex.Playlists do
  @moduledoc """
  Client for MPD (Music Player Daemon)
  """

  def list(host, port) do
    case Mpdex.Client.send("listplaylists", host: host, port: port) do
      {:ok, raw_lists} ->
        raw_lists
        |> String.split("\n")
        |> Enum.chunk_every(2)
        |> Enum.reduce([], fn entry, acc ->
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

  def get(list_name, host, port) do
    case Mpdex.Client.send("listplaylistinfo #{list_name}", host: host, port: port) do
      {:ok, content} ->
        [_ | raw_songs] = String.split(content, "file: ")

        songs =
          raw_songs
          |> Enum.reduce([], fn line, acc ->
            [file | raw_metadata] = String.split(line, "\n")
            metadata = parse_metadata(raw_metadata) |> Enum.into(%{})

            [[{:file, file}, {:metadata, metadata}] | acc]
          end)
          |> Enum.reverse()

        {:ok, songs}

      _ ->
        []
    end
  end

  def load(list_name, host, port) do
    case Mpdex.Client.send("load #{list_name}", host: host, port: port) do
      {:ok, _} ->
        {:ok, :loaded}

      {:error, err} ->
        {:error, err}
    end
  end

  defp parse_metadata(metadata) do
    Enum.map(metadata, fn md ->
      case md do
        <<"Artist: ", artist::binary>> ->
          {:artist, artist}

        <<"Album: ", album::binary>> ->
          {:album, album}

        <<"Disc: ", disc::binary>> ->
          {:disc, disc}

        <<"Duration: ", raw_duration::binary>> ->
          duration =
            if String.contains?(raw_duration, ".") do
              raw_duration
            else
              "#{raw_duration}.0"
            end
            |> String.to_float()

          {:duration, duration}

        <<"Genre: ", genre::binary>> ->
          {:genre, genre}

        <<"Last-Modified: ", last_modified::binary>> ->
          modified =
            case DateTime.from_iso8601(last_modified) do
              {:ok, modified_time, _} ->
                modified_time

              {:error, _} ->
                nil
            end

          {:last_modified, modified}

        <<"Name: ", name::binary>> ->
          {:name, name}

        <<"Time: ", time::binary>> ->
          {:time, String.to_integer(time)}

        <<"Title: ", title::binary>> ->
          {:title, title}

        <<"Track: ", track::binary>> ->
          {:tract, track}

        rest ->
          {:undefined, rest}
      end
    end)
  end
end
