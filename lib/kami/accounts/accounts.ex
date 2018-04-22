defmodule Kami.Accounts do
  require Logger
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Kami.Repo

  alias Kami.Accounts.User
  alias Kami.Accounts.Character

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get(id) do
    Repo.get(User, id)
  end

  def get_by(%{"username" => user}) do
    Repo.get_by(User, username: user)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    {res, user} = %User{admin: false}
    |> User.registration_changeset(attrs)
    |> Repo.insert()

    if res == :ok do
      case create_character(user, %{name: (user.name |> String.capitalize), approved: false, image: "", family: "New Account", air: 1, water: 1, earth: 1, fire: 1, void: 1}) do
        {:ok, _} ->
          {:ok, user}
        _ ->
          {:error, "Error creating character for new user."}
      end
    else
      {:error, user}
    end
  end

  def create_admin(attrs \\ %{}) do
    %User{admin: true}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def is_admin?(id) do
    user = get(id)
    user.admin
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.registration_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.registration_changeset(user, %{})
  end

  @doc """
  Returns the list of characters.

  ## Examples

      iex> list_characters()
      [%Character{}, ...]

  """
  def list_characters do
    Repo.all(Character)
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!(123)
      %Character{}

      iex> get_character!(456)
      ** (Ecto.NoResultsError)

  """
  def get_character!(id), do: Repo.get!(Character, id)

  def get_character_by_name!(name) do
    Repo.get_by!(Character, name: String.capitalize(name))
  end

  def get_PC_for(id) do
    user = User |> Repo.get(id) |> Repo.preload(:characters)
    List.first(user.characters)
  end

  def get_characters(id) do
    User
    |> Repo.get(id)
    |> Repo.preload(:characters)
    |> Map.get(:characters)
  end

  def image_url(%Character{} = character) do
    if character.image.file_name == "" do "" else Kami.Avatar.url({character.image, character}) end
  end

  @doc """
  Creates a character.

  ## Examples

      iex> create_character(%{field: value})
      {:ok, %Character{}}

      iex> create_character(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_character(%User{} = user, attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  def update_character_description(%Character{} = character, attrs) do
    character
    |> Character.description_changeset(attrs)
    |> Repo.update()
  end

  def update_pre_approval(%Character{} = character, attrs) do
    character
    |> Character.pre_approval_changeset(attrs)
    |> Repo.update()
  end

  def update_image(%Character{} = character, attrs) do
    character
    |> Character.image_changeset(attrs)
    |> Repo.update()
  end

  def update_stat(%Character{} = character, stat_key, delta) do
    try do
      atom = String.to_existing_atom(stat_key)
      current_stat = Map.get(character, atom)
      new_value = current_stat + delta
      if ((stat_key == "void_points" and new_value > character.void) or (stat_key == "strife" and new_value > (character.earth + character.fire) * 2)) do
        {:error, "cannot modify a stat below 0 or above any relevant stat cap"}
      else
        delta = if stat_key == "strife" and new_value < 0 do -1 * current_stat else delta end
        character
        |> Character.stat_changeset(%{atom => current_stat + delta})
        |> Repo.update()
      end
    rescue
      _ in ArgumentError -> {:error, "invalid stat key"}
      _ in ArithmeticError -> {:error, "invalid stat delta"}
    end
  end

  def award_bxp(%Character{} = character) do
    bxp_max = Application.get_env(:kami, :bxp_per_week_max) + if character.patreon do Application.get_env(:kami, :bxp_per_week_patreon_bonus) else 0 end
    if character.bxp_this_week + Application.get_env(:kami, :bxp_per_post) <= bxp_max do
      character
      |> Character.stat_changeset(%{bxp: Float.round(character.bxp + Application.get_env(:kami, :bxp_per_post), 2),
                                    bxp_this_week: Float.round(character.bxp_this_week + Application.get_env(:kami, :bxp_per_post), 2)})
      |> Repo.update()
    end
  end

  def award_xp(%Character{} = character, amount) do
    {new_bxp, to_unlock} = if character.bxp >= amount do
      {character.bxp - amount, amount}
    else
      {0, character.bxp}
    end
    xp = amount + to_unlock
    character
    |> Character.stat_changeset(%{bxp: if new_bxp != 0 do Float.round(new_bxp, 2) else 0 end,
                                  xp: Float.round(character.xp + xp,2),
                                  total_xp: Float.round(character.total_xp + xp, 2) })
    |> Repo.update()
  end

  def timer_award_xp() do
    Character
    |> Repo.all
    |> Enum.each(fn(character) -> award_xp(character, Application.get_env(:kami, :xp_per_week)) end)
  end

  def timer_reset_bxp() do
    Character
    |> Repo.update_all(set: [bxp_this_week: 0])
  end

  def buy_upgrade_for_stat(%Character{} = character, stat_key) do
    try do
      atom = String.to_existing_atom(stat_key)
      current_stat = Map.get(character, atom)
      current_xp = Map.get(character, :xp)
      multiplier = if Enum.member?(["void", "air", "earth", "fire", "water"], stat_key) do 3 else 2 end
      new_value = current_stat + 1
      cost = new_value * multiplier
      new_xp = current_xp - cost
      least_ring = Enum.min([character.void, character.air, character.earth, character.fire, character.water])
      if Enum.member?(["void", "air", "earth", "fire", "water"], stat_key) and (new_value > (least_ring + character.void)) do
        {:error, "tried to increase a ring above its maximum value"}
      else
        if new_xp >= 0 do
          character
          |> Character.stat_changeset(%{atom => new_value, :xp => new_xp})
          |> Repo.update()
        else
          {:error, "tried to purchase a stat increase you cannot afford"}
        end
      end
    rescue
      _ in ArgumentError -> {:error, "invalid stat key"}
    end
  end

  @doc """
  Deletes a Character.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character changes.

  ## Examples

      iex> change_character(character)
      %Ecto.Changeset{source: %Character{}}

  """
  def change_character(%Character{} = character) do
    Character.changeset(character, %{})
  end

  def change_character_description(%Character{} = character) do
    Character.description_changeset(character, %{})
  end

  def change_before_approval(%Character{} = character) do
    Character.pre_approval_changeset(character, %{})
  end

  def change_image(%Character{} = character) do
    Character.image_changeset(character, %{})
  end
end
