defmodule Kami.AccountsTest do
  use Kami.DataCase

  alias Kami.Accounts

  describe "users" do
    alias Kami.Accounts.User

    @valid_attrs %{name: "some name", username: "some username"}
    @update_attrs %{name: "some updated name", username: "some updated username"}
    @invalid_attrs %{name: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == "some name"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.name == "some updated name"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "credentials" do
    alias Kami.Accounts.Credential

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_credential()

      credential
    end

    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert Accounts.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert Accounts.get_credential!(credential.id) == credential
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Accounts.create_credential(@valid_attrs)
      assert credential.email == "some email"
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_credential(@invalid_attrs)
    end

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()
      assert {:ok, credential} = Accounts.update_credential(credential, @update_attrs)
      assert %Credential{} = credential
      assert credential.email == "some updated email"
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_credential(credential, @invalid_attrs)
      assert credential == Accounts.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Accounts.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Accounts.change_credential(credential)
    end
  end

  describe "users" do
    alias Kami.Accounts.User

    @valid_attrs %{crypted_password: "some crypted_password", name: "some name"}
    @update_attrs %{crypted_password: "some updated crypted_password", name: "some updated name"}
    @invalid_attrs %{crypted_password: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.crypted_password == "some crypted_password"
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.crypted_password == "some updated crypted_password"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "characters" do
    alias Kami.Accounts.Character

    @valid_attrs %{strife: 42, school: "some school", air: 42, skill_melee: 42, skill_sentiment: 42, skill_courtesy: 42, name: "some name", public_description: "some public_description", ninjo: "some ninjo", skill_survival: 42, skill_smithing: 42, questions: "some questions", skill_government: 42, outburst: "some outburst", skill_games: 42, skill_performance: 42, adversities: "some adversities", armor: "some armor", techniques: "some techniques", fire: 42, skill_skullduggery: 42, skill_aesthetics: 42, bxp_this_week: 120.5, approved: true, skill_meditation: 42, total_xp: 120.5, bxp: 120.5, skill_medicine: 42, skill_labor: 42, skill_theology: 42, void_points_max: 42, passions: "some passions", skill_design: 42, skill_culture: 42, distinctions: "some distinctions", images: [], giri: "some giri", xp: 120.5, weapons: "some weapons", honor: 42, skill_iaijutsu: 42, skill_fitness: 42, clan: "some clan", skill_ranged: 42, void: 42, anxieties: "some anxieties", skill_composition: 42, water: 42, skill_command: 42, family: "some family", ...}
    @update_attrs %{strife: 43, school: "some updated school", air: 43, skill_melee: 43, skill_sentiment: 43, skill_courtesy: 43, name: "some updated name", public_description: "some updated public_description", ninjo: "some updated ninjo", skill_survival: 43, skill_smithing: 43, questions: "some updated questions", skill_government: 43, outburst: "some updated outburst", skill_games: 43, skill_performance: 43, adversities: "some updated adversities", armor: "some updated armor", techniques: "some updated techniques", fire: 43, skill_skullduggery: 43, skill_aesthetics: 43, bxp_this_week: 456.7, approved: false, skill_meditation: 43, total_xp: 456.7, bxp: 456.7, skill_medicine: 43, skill_labor: 43, skill_theology: 43, void_points_max: 43, passions: "some updated passions", skill_design: 43, skill_culture: 43, distinctions: "some updated distinctions", images: [], giri: "some updated giri", xp: 456.7, weapons: "some updated weapons", honor: 43, skill_iaijutsu: 43, skill_fitness: 43, clan: "some updated clan", skill_ranged: 43, void: 43, anxieties: "some updated anxieties", skill_composition: 43, water: 43, skill_command: 43, family: "some updated family", ...}
    @invalid_attrs %{strife: nil, school: nil, air: nil, skill_melee: nil, skill_sentiment: nil, skill_courtesy: nil, name: nil, public_description: nil, ninjo: nil, skill_survival: nil, skill_smithing: nil, questions: nil, skill_government: nil, outburst: nil, skill_games: nil, skill_performance: nil, adversities: nil, armor: nil, techniques: nil, fire: nil, skill_skullduggery: nil, skill_aesthetics: nil, bxp_this_week: nil, approved: nil, skill_meditation: nil, total_xp: nil, bxp: nil, skill_medicine: nil, skill_labor: nil, skill_theology: nil, void_points_max: nil, passions: nil, skill_design: nil, skill_culture: nil, distinctions: nil, images: nil, giri: nil, xp: nil, weapons: nil, honor: nil, skill_iaijutsu: nil, skill_fitness: nil, clan: nil, skill_ranged: nil, void: nil, anxieties: nil, skill_composition: nil, water: nil, skill_command: nil, family: nil, ...}

    def character_fixture(attrs \\ %{}) do
      {:ok, character} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_character()

      character
    end

    test "list_characters/0 returns all characters" do
      character = character_fixture()
      assert Accounts.list_characters() == [character]
    end

    test "get_character!/1 returns the character with given id" do
      character = character_fixture()
      assert Accounts.get_character!(character.id) == character
    end

    test "create_character/1 with valid data creates a character" do
      assert {:ok, %Character{} = character} = Accounts.create_character(@valid_attrs)
      assert character.strife == 42
      assert character.school == "some school"
      assert character.air == 42
      assert character.skill_melee == 42
      assert character.skill_sentiment == 42
      assert character.skill_courtesy == 42
      assert character.name == "some name"
      assert character.public_description == "some public_description"
      assert character.ninjo == "some ninjo"
      assert character.skill_survival == 42
      assert character.skill_smithing == 42
      assert character.questions == "some questions"
      assert character.skill_government == 42
      assert character.outburst == "some outburst"
      assert character.skill_games == 42
      assert character.skill_performance == 42
      assert character.adversities == "some adversities"
      assert character.armor == "some armor"
      assert character.techniques == "some techniques"
      assert character.fire == 42
      assert character.skill_skullduggery == 42
      assert character.skill_aesthetics == 42
      assert character.bxp_this_week == 120.5
      assert character.approved == true
      assert character.skill_meditation == 42
      assert character.total_xp == 120.5
      assert character.bxp == 120.5
      assert character.skill_medicine == 42
      assert character.skill_labor == 42
      assert character.skill_theology == 42
      assert character.void_points_max == 42
      assert character.passions == "some passions"
      assert character.skill_design == 42
      assert character.skill_culture == 42
      assert character.distinctions == "some distinctions"
      assert character.images == []
      assert character.giri == "some giri"
      assert character.xp == 120.5
      assert character.weapons == "some weapons"
      assert character.honor == 42
      assert character.skill_iaijutsu == 42
      assert character.skill_fitness == 42
      assert character.clan == "some clan"
      assert character.skill_ranged == 42
      assert character.void == 42
      assert character.anxieties == "some anxieties"
      assert character.skill_composition == 42
      assert character.water == 42
      assert character.skill_command == 42
      assert character.family == "some family"
      assert character.school_rank == 42
      assert character.skill_unarmed == 42
      assert character.skill_seafaring == 42
      assert character.earth == 42
      assert character.glory == 42
      assert character.skill_commerce == 42
      assert character.status == 42
      assert character.skill_tactics == 42
      assert character.void_points == 42
      assert character.titles == "some titles"
      assert character.total_spent_xp == 42
    end

    test "create_character/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_character(@invalid_attrs)
    end

    test "update_character/2 with valid data updates the character" do
      character = character_fixture()
      assert {:ok, character} = Accounts.update_character(character, @update_attrs)
      assert %Character{} = character
      assert character.strife == 43
      assert character.school == "some updated school"
      assert character.air == 43
      assert character.skill_melee == 43
      assert character.skill_sentiment == 43
      assert character.skill_courtesy == 43
      assert character.name == "some updated name"
      assert character.public_description == "some updated public_description"
      assert character.ninjo == "some updated ninjo"
      assert character.skill_survival == 43
      assert character.skill_smithing == 43
      assert character.questions == "some updated questions"
      assert character.skill_government == 43
      assert character.outburst == "some updated outburst"
      assert character.skill_games == 43
      assert character.skill_performance == 43
      assert character.adversities == "some updated adversities"
      assert character.armor == "some updated armor"
      assert character.techniques == "some updated techniques"
      assert character.fire == 43
      assert character.skill_skullduggery == 43
      assert character.skill_aesthetics == 43
      assert character.bxp_this_week == 456.7
      assert character.approved == false
      assert character.skill_meditation == 43
      assert character.total_xp == 456.7
      assert character.bxp == 456.7
      assert character.skill_medicine == 43
      assert character.skill_labor == 43
      assert character.skill_theology == 43
      assert character.void_points_max == 43
      assert character.passions == "some updated passions"
      assert character.skill_design == 43
      assert character.skill_culture == 43
      assert character.distinctions == "some updated distinctions"
      assert character.images == []
      assert character.giri == "some updated giri"
      assert character.xp == 456.7
      assert character.weapons == "some updated weapons"
      assert character.honor == 43
      assert character.skill_iaijutsu == 43
      assert character.skill_fitness == 43
      assert character.clan == "some updated clan"
      assert character.skill_ranged == 43
      assert character.void == 43
      assert character.anxieties == "some updated anxieties"
      assert character.skill_composition == 43
      assert character.water == 43
      assert character.skill_command == 43
      assert character.family == "some updated family"
      assert character.school_rank == 43
      assert character.skill_unarmed == 43
      assert character.skill_seafaring == 43
      assert character.earth == 43
      assert character.glory == 43
      assert character.skill_commerce == 43
      assert character.status == 43
      assert character.skill_tactics == 43
      assert character.void_points == 43
      assert character.titles == "some updated titles"
      assert character.total_spent_xp == 43
    end

    test "update_character/2 with invalid data returns error changeset" do
      character = character_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_character(character, @invalid_attrs)
      assert character == Accounts.get_character!(character.id)
    end

    test "delete_character/1 deletes the character" do
      character = character_fixture()
      assert {:ok, %Character{}} = Accounts.delete_character(character)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_character!(character.id) end
    end

    test "change_character/1 returns a character changeset" do
      character = character_fixture()
      assert %Ecto.Changeset{} = Accounts.change_character(character)
    end
  end
end
