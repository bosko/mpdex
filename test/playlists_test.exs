defmodule Mpdex.PlaylistsTest do
  use ExUnit.Case
  doctest Mpdex.Playlists

  test "gets the the list of play lists" do
    {:ok, modified, _} = DateTime.from_iso8601("2018-11-24T18:40:08Z")

    assert Mpdex.Playlists.list() == [[playlist: "Classic", last_modified: modified]]
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

    assert Mpdex.Playlists.get("dummy") == {:ok, expected}
  end

  test "sends command to load list" do
    assert Mpdex.Playlists.load("dummy") == {:ok, "OK\n"}
  end

  test "sends command to add url to list" do
    assert Mpdex.Playlists.add_to_list("dummy", "http://example.com") == {:ok, "OK\n"}
  end

  test "sends command to clear list" do
    assert Mpdex.Playlists.clear("dummy") == {:ok, "OK\n"}
  end

  test "sends command to delete song from list" do
    assert Mpdex.Playlists.delete_song_at("dummy", 1) == {:ok, "OK\n"}
  end

  test "sends command to move song" do
    assert Mpdex.Playlists.move_song("dummy", 2, 1) == {:ok, "OK\n"}
  end

  test "sends command to save queue to list" do
    assert Mpdex.Playlists.save_queue_to_list("dummy_1") == {:ok, "OK\n"}
  end

  test "sends command to rename list" do
    assert Mpdex.Playlists.rename("dummy", "old-dummy") == {:ok, "OK\n"}
  end

  test "sends command to delete list" do
    assert Mpdex.Playlists.delete("dummy") == {:ok, "OK\n"}
  end
end
