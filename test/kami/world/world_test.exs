defmodule Kami.WorldTest do
  use Kami.DataCase

  alias Kami.World

  describe "posts" do
    alias Kami.World.Post

    @valid_attrs %{diceroll: true, die_size: 42, glory: 42, honor: 42, image: "some image", name: "some name", narrative: true, ooc: true, results: [], ring_name: "some ring_name", ring_value: 42, skill_name: "some skill_name", skillroll: true, status: 42, text: "some text"}
    @update_attrs %{diceroll: false, die_size: 43, glory: 43, honor: 43, image: "some updated image", name: "some updated name", narrative: false, ooc: false, results: [], ring_name: "some updated ring_name", ring_value: 43, skill_name: "some updated skill_name", skillroll: false, status: 43, text: "some updated text"}
    @invalid_attrs %{diceroll: nil, die_size: nil, glory: nil, honor: nil, image: nil, name: nil, narrative: nil, ooc: nil, results: nil, ring_name: nil, ring_value: nil, skill_name: nil, skillroll: nil, status: nil, text: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> World.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert World.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert World.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = World.create_post(@valid_attrs)
      assert post.diceroll == true
      assert post.die_size == 42
      assert post.glory == 42
      assert post.honor == 42
      assert post.image == "some image"
      assert post.name == "some name"
      assert post.narrative == true
      assert post.ooc == true
      assert post.results == []
      assert post.ring_name == "some ring_name"
      assert post.ring_value == 42
      assert post.skill_name == "some skill_name"
      assert post.skillroll == true
      assert post.status == 42
      assert post.text == "some text"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = World.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, post} = World.update_post(post, @update_attrs)
      assert %Post{} = post
      assert post.diceroll == false
      assert post.die_size == 43
      assert post.glory == 43
      assert post.honor == 43
      assert post.image == "some updated image"
      assert post.name == "some updated name"
      assert post.narrative == false
      assert post.ooc == false
      assert post.results == []
      assert post.ring_name == "some updated ring_name"
      assert post.ring_value == 43
      assert post.skill_name == "some updated skill_name"
      assert post.skillroll == false
      assert post.status == 43
      assert post.text == "some updated text"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = World.update_post(post, @invalid_attrs)
      assert post == World.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = World.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> World.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = World.change_post(post)
    end
  end

  describe "locations" do
    alias Kami.World.Location

    @valid_attrs %{description: "some description", locked: true, name: "some name", ooc: true}
    @update_attrs %{description: "some updated description", locked: false, name: "some updated name", ooc: false}
    @invalid_attrs %{description: nil, locked: nil, name: nil, ooc: nil}

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> World.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert World.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert World.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = World.create_location(@valid_attrs)
      assert location.description == "some description"
      assert location.locked == true
      assert location.name == "some name"
      assert location.ooc == true
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = World.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, location} = World.update_location(location, @update_attrs)
      assert %Location{} = location
      assert location.description == "some updated description"
      assert location.locked == false
      assert location.name == "some updated name"
      assert location.ooc == false
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = World.update_location(location, @invalid_attrs)
      assert location == World.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = World.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> World.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = World.change_location(location)
    end
  end

  describe "letters" do
    alias Kami.World.Letter

    @valid_attrs %{description: "some description", text: "some text", to_postmaster: true}
    @update_attrs %{description: "some updated description", text: "some updated text", to_postmaster: false}
    @invalid_attrs %{description: nil, text: nil, to_postmaster: nil}

    def letter_fixture(attrs \\ %{}) do
      {:ok, letter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> World.create_letter()

      letter
    end

    test "list_letters/0 returns all letters" do
      letter = letter_fixture()
      assert World.list_letters() == [letter]
    end

    test "get_letter!/1 returns the letter with given id" do
      letter = letter_fixture()
      assert World.get_letter!(letter.id) == letter
    end

    test "create_letter/1 with valid data creates a letter" do
      assert {:ok, %Letter{} = letter} = World.create_letter(@valid_attrs)
      assert letter.description == "some description"
      assert letter.text == "some text"
      assert letter.to_postmaster == true
    end

    test "create_letter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = World.create_letter(@invalid_attrs)
    end

    test "update_letter/2 with valid data updates the letter" do
      letter = letter_fixture()
      assert {:ok, letter} = World.update_letter(letter, @update_attrs)
      assert %Letter{} = letter
      assert letter.description == "some updated description"
      assert letter.text == "some updated text"
      assert letter.to_postmaster == false
    end

    test "update_letter/2 with invalid data returns error changeset" do
      letter = letter_fixture()
      assert {:error, %Ecto.Changeset{}} = World.update_letter(letter, @invalid_attrs)
      assert letter == World.get_letter!(letter.id)
    end

    test "delete_letter/1 deletes the letter" do
      letter = letter_fixture()
      assert {:ok, %Letter{}} = World.delete_letter(letter)
      assert_raise Ecto.NoResultsError, fn -> World.get_letter!(letter.id) end
    end

    test "change_letter/1 returns a letter changeset" do
      letter = letter_fixture()
      assert %Ecto.Changeset{} = World.change_letter(letter)
    end
  end
end
