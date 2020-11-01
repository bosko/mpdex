defmodule Mpdex.Parser do
  def parse_list_of_play_lists(raw_lists) do
    raw_lists
    |> String.split("\n")
    |> Enum.chunk_every(2)
    |> Enum.reduce([], fn entry, acc ->
      case entry do
        [<<"playlist: ", list::binary>>, <<"Last-Modified: ", modified::binary>>] ->
          modified =
            case DateTime.from_iso8601(modified) do
              {:ok, date_time, _} ->
                date_time

              _ ->
                nil
            end

          [%{playlist: list, last_modified: modified} | acc]

        _ ->
          acc
      end
    end)
    |> Enum.reverse()
  end

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
          |> fill_missing_metadata(file)

        [%{file: file, metadata: metadata} | acc]
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

  def parse_key_value(raw_value) do
    raw_value
    |> String.split("\n")
    |> Enum.map(fn val ->
      case String.split(val, ": ") do
        ["audio", value] ->
          [sample, bits, channels] = String.split(value, ":")
          {:audio, [{:samplerate, sample}, {:bits, bits}, {:channels, channels}]}

        [status, value] ->
          {String.to_atom(status), value}

        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil(&1))
    |> Enum.into(%{})
  end

  defp fill_missing_metadata(metadata, file) do
    [artist, album, title] = extract_from_file_path(file)

    metadata =
      if false == Map.has_key?(metadata, :artist) do
        Map.put(metadata, :artist, artist)
      else
        metadata
      end

    metadata =
      if false == Map.has_key?(metadata, :album) do
        Map.put(metadata, :album, album)
      else
        metadata
      end

    metadata =
      if false == Map.has_key?(metadata, :title) do
        Map.put(metadata, :title, title)
      else
        metadata
      end

    if false == Map.has_key?(metadata, :time) do
      Map.put(metadata, :time, 0)
    else
      metadata
    end
  end

  defp extract_from_file_path(file_path) do
    if String.starts_with?(file_path, "http") do
      ["Unknown", "Unknown", file_path]
    else
      paths = Path.dirname(file_path) |> String.split("/")

      [artist, album] =
        case length(paths) do
          1 ->
            [hd(paths), "Unknown"]

          2 ->
            paths

          _ ->
            [artist | [album | _]] = paths
            [artist, album]
        end

      name = Path.basename(file_path, Path.extname(file_path))

      [artist, album, name]
    end
  end
end
