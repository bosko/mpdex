defmodule Mpdex.PlaylistsTest do
  use ExUnit.Case
  doctest Mpdex.Playlists

  test "gets the the list of play lists" do
    {:ok, modified, _} = DateTime.from_iso8601("2018-11-24T18:40:08Z")

    assert Mpdex.Playlists.list("", "") == [[playlist: "Classic", last_modified: modified]]
  end

  test "gets sons from the single list" do
    {:ok, modified, _} = DateTime.from_iso8601("2017-05-08T16:17:30Z")
    expected =
      [
        [
          file: "Classic/Debussy-jeux-de-vagues.mp3",
          metadata: %{
            last_modified: modified,
            name: "Jeux de vagues",
            title: "(La Mer) - II. Jeux de vagues. Allegro",
            album: "Seascapes",
            disc: "1/1",
            track: "2/9",
            genre: ["Romantic", "Classical", "Classical", "Orchestral"],
            artist: "Debussy",
            time: 418,
            undefined: ["", "Date: 2007", "Composer: Debussy, Claude"]
          }
        ]
      ]

    assert Mpdex.Playlists.get("dummy", "", "") == {:ok, expected}
  end
end
