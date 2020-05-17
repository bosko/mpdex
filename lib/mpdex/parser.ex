defmodule Mpdex.Parser do
  def parse_play_list(raw_list) do
    [_ | raw_songs] = String.split(raw_list, "file: ")

    songs =
      raw_songs
      |> Enum.reduce([], fn line, acc ->
      [file | raw_metadata] = String.split(line, "\n")

      metadata =
        parse_metadata(raw_metadata)
        |> Enum.reduce(%{}, fn {key, val}, acc ->
        case acc do
          %{^key => existing} when is_binary(existing) ->
            Map.put(acc, key, [existing, val])

          %{^key => existing} when is_list(existing) ->
            Map.put(acc, key, [val | existing])

          _ ->
            Map.put(acc, key, val)
        end
      end)

        [[{:file, file}, {:metadata, metadata}] | acc]
    end)
    |> Enum.reverse()

      {:ok, songs}
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

        <<"duration: ", raw_duration::binary>> ->
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

        <<"Id: ", id::binary>> ->
          {:id, id}

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

        <<"Pos: ", position::binary>> ->
          {:position, String.to_integer(position)}

        <<"Time: ", time::binary>> ->
          {:time, String.to_integer(time)}

        <<"Title: ", title::binary>> ->
          {:title, title}

        <<"Track: ", track::binary>> ->
          {:track, track}

        rest ->
          {:undefined, rest}
      end
    end)
  end
end
