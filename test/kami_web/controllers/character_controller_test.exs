defmodule KamiWeb.CharacterControllerTest do
  use KamiWeb.ConnCase

  alias Kami.Accounts

  @create_attrs %{strife: 42, school: "some school", air: 42, skill_melee: 42, skill_sentiment: 42, skill_courtesy: 42, name: "some name", public_description: "some public_description", ninjo: "some ninjo", skill_survival: 42, skill_smithing: 42, questions: "some questions", skill_government: 42, outburst: "some outburst", skill_games: 42, skill_performance: 42, adversities: "some adversities", armor: "some armor", techniques: "some techniques", fire: 42, skill_skullduggery: 42, skill_aesthetics: 42, bxp_this_week: 120.5, approved: true, skill_meditation: 42, total_xp: 120.5, bxp: 120.5, skill_medicine: 42, skill_labor: 42, skill_theology: 42, void_points_max: 42, passions: "some passions", skill_design: 42, skill_culture: 42, distinctions: "some distinctions", images: [], giri: "some giri", xp: 120.5, weapons: "some weapons", honor: 42, skill_iaijutsu: 42, skill_fitness: 42, clan: "some clan", skill_ranged: 42, void: 42, anxieties: "some anxieties", skill_composition: 42, water: 42, skill_command: 42, family: "some family", ...}
  @update_attrs %{strife: 43, school: "some updated school", air: 43, skill_melee: 43, skill_sentiment: 43, skill_courtesy: 43, name: "some updated name", public_description: "some updated public_description", ninjo: "some updated ninjo", skill_survival: 43, skill_smithing: 43, questions: "some updated questions", skill_government: 43, outburst: "some updated outburst", skill_games: 43, skill_performance: 43, adversities: "some updated adversities", armor: "some updated armor", techniques: "some updated techniques", fire: 43, skill_skullduggery: 43, skill_aesthetics: 43, bxp_this_week: 456.7, approved: false, skill_meditation: 43, total_xp: 456.7, bxp: 456.7, skill_medicine: 43, skill_labor: 43, skill_theology: 43, void_points_max: 43, passions: "some updated passions", skill_design: 43, skill_culture: 43, distinctions: "some updated distinctions", images: [], giri: "some updated giri", xp: 456.7, weapons: "some updated weapons", honor: 43, skill_iaijutsu: 43, skill_fitness: 43, clan: "some updated clan", skill_ranged: 43, void: 43, anxieties: "some updated anxieties", skill_composition: 43, water: 43, skill_command: 43, family: "some updated family", ...}
  @invalid_attrs %{strife: nil, school: nil, air: nil, skill_melee: nil, skill_sentiment: nil, skill_courtesy: nil, name: nil, public_description: nil, ninjo: nil, skill_survival: nil, skill_smithing: nil, questions: nil, skill_government: nil, outburst: nil, skill_games: nil, skill_performance: nil, adversities: nil, armor: nil, techniques: nil, fire: nil, skill_skullduggery: nil, skill_aesthetics: nil, bxp_this_week: nil, approved: nil, skill_meditation: nil, total_xp: nil, bxp: nil, skill_medicine: nil, skill_labor: nil, skill_theology: nil, void_points_max: nil, passions: nil, skill_design: nil, skill_culture: nil, distinctions: nil, images: nil, giri: nil, xp: nil, weapons: nil, honor: nil, skill_iaijutsu: nil, skill_fitness: nil, clan: nil, skill_ranged: nil, void: nil, anxieties: nil, skill_composition: nil, water: nil, skill_command: nil, family: nil, ...}

  def fixture(:character) do
    {:ok, character} = Accounts.create_character(@create_attrs)
    character
  end

  describe "index" do
    test "lists all characters", %{conn: conn} do
      conn = get conn, character_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Characters"
    end
  end

  describe "new character" do
    test "renders form", %{conn: conn} do
      conn = get conn, character_path(conn, :new)
      assert html_response(conn, 200) =~ "New Character"
    end
  end

  describe "create character" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, character_path(conn, :create), character: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == character_path(conn, :show, id)

      conn = get conn, character_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Character"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, character_path(conn, :create), character: @invalid_attrs
      assert html_response(conn, 200) =~ "New Character"
    end
  end

  describe "edit character" do
    setup [:create_character]

    test "renders form for editing chosen character", %{conn: conn, character: character} do
      conn = get conn, character_path(conn, :edit, character)
      assert html_response(conn, 200) =~ "Edit Character"
    end
  end

  describe "update character" do
    setup [:create_character]

    test "redirects when data is valid", %{conn: conn, character: character} do
      conn = put conn, character_path(conn, :update, character), character: @update_attrs
      assert redirected_to(conn) == character_path(conn, :show, character)

      conn = get conn, character_path(conn, :show, character)
      assert html_response(conn, 200) =~ "some updated school"
    end

    test "renders errors when data is invalid", %{conn: conn, character: character} do
      conn = put conn, character_path(conn, :update, character), character: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Character"
    end
  end

  describe "delete character" do
    setup [:create_character]

    test "deletes chosen character", %{conn: conn, character: character} do
      conn = delete conn, character_path(conn, :delete, character)
      assert redirected_to(conn) == character_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, character_path(conn, :show, character)
      end
    end
  end

  defp create_character(_) do
    character = fixture(:character)
    {:ok, character: character}
  end
end
