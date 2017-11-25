defmodule Kami.World do
  @moduledoc """
  The World context.
  """

  import Ecto.Query, warn: false
  alias Kami.Repo

  alias Kami.World.Post
  alias Kami.World.Location

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  def get_posts!(location_id) do
    Post
    |> where([p], p.location_id == type(^location_id, :integer))
    |> order_by(asc: :inserted_at)
    |> Repo.all
  end

  def get_posts!(location_id, limit) do
    Post
    |> where([p], p.location_id == type(^location_id, :integer))
    |> order_by(asc: :inserted_at)
    |> limit(type(^limit, :integer))
    |> Repo.all
  end

  def get_backfill!(location_id, limit) do
    Post
    |> where([p], p.location_id == type(^location_id, :integer))
    |> order_by(desc: :inserted_at)
    |> limit(type(^limit, :integer))
    |> Repo.all
  end

  def get_recent_post_authors(1) do
    Post
    |> where([p], p.ooc == false and p.location_id != 1)
    |> order_by(desc: :inserted_at)
    |> limit(100)
    |> Repo.all
    |> Repo.preload([:location])
    |> Enum.map(fn(p) -> %{location: p.location.name, location_slug: p.location.slug, author: String.capitalize(p.author_slug),
      ts: Timex.to_datetime(p.inserted_at) |> Timex.Timezone.convert("America/Chicago") |> Timex.format!("at {h24}:{m} on {WDfull}, {D} {Mshort} {YYYY}")} end)
    |> Enum.filter(fn(p) -> p.author != "" and p.author != "[narrative]" end)
    |> filter_ignoring_timestamps
    |> Enum.take(10)
  end

  def get_recent_post_authors(location_id) do
    Post
    |> where([p], p.ooc == false and p.location_id == ^location_id)
    |> order_by(desc: :inserted_at)
    |> limit(100)
    |> Repo.all
    |> Repo.preload([:location])
    |> Enum.map(fn(p) -> %{location: p.location.name, location_slug: p.location.slug, author: String.capitalize(p.author_slug),
      ts: Timex.to_datetime(p.inserted_at) |> Timex.Timezone.convert("America/Chicago") |> Timex.format!("at {h24}:{m} on {WDfull}, {D} {Mshort} {YYYY}")} end)
    |> Enum.filter(fn(p) -> p.author != "" and p.author != "[narrative]" end)
    |> filter_ignoring_timestamps
    |> Enum.take(5)
  end

  defp filter_ignoring_timestamps(posts) do
    filter_ignoring_timestamps(posts, MapSet.new)
  end

  defp filter_ignoring_timestamps([x|rest], found) do
    if MapSet.member?(found, {x.author, x.location_slug}) do
      filter_ignoring_timestamps(rest, found)
    else
      [x | filter_ignoring_timestamps(rest, MapSet.put(found, {x.author, x.location_slug}))]
    end
  end

  defp filter_ignoring_timestamps([], _) do
    []
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(location_id, author_slug, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_change(:location_id, location_id)
    |> Ecto.Changeset.put_change(:author_slug, author_slug)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  def list_locations_with_posts do
    Location
    |> Repo.all
    |> Repo.preload([:posts])
    |> Enum.filter(fn(location) -> Enum.count(location.posts) > 1 end)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id) do
    Location
    |> Repo.get!(id)
    |> Repo.preload([:children, :parent])
  end

  def get_location_by_slug!(slug) do
    Location
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:children, :parent])
  end

  def is_ooc?(id) do
    location = get_location!(id)
    location.ooc
  end

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def create_location(%Location{} = parent, attrs) do
    %Location{}
    |> Location.changeset(attrs)
    |> Ecto.Changeset.put_change(:parent_id, parent.id)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{source: %Location{}}

  """
  def change_location(%Location{} = location) do
    Location.changeset(location, %{})
  end

  alias Kami.World.Letter

  @doc """
  Returns the list of letters.

  ## Examples

      iex> list_letters()
      [%Letter{}, ...]

  """
  def list_letters do
    Repo.all(Letter)
  end

  @doc """
  Gets a single letter.

  Raises `Ecto.NoResultsError` if the Letter does not exist.

  ## Examples

      iex> get_letter!(123)
      %Letter{}

      iex> get_letter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_letter!(id), do: Repo.get!(Letter, id)

  @doc """
  Creates a letter.

  ## Examples

      iex> create_letter(%{field: value})
      {:ok, %Letter{}}

      iex> create_letter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_letter(attrs \\ %{}) do
    %Letter{}
    |> Letter.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a letter.

  ## Examples

      iex> update_letter(letter, %{field: new_value})
      {:ok, %Letter{}}

      iex> update_letter(letter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_letter(%Letter{} = letter, attrs) do
    letter
    |> Letter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Letter.

  ## Examples

      iex> delete_letter(letter)
      {:ok, %Letter{}}

      iex> delete_letter(letter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_letter(%Letter{} = letter) do
    Repo.delete(letter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking letter changes.

  ## Examples

      iex> change_letter(letter)
      %Ecto.Changeset{source: %Letter{}}

  """
  def change_letter(%Letter{} = letter) do
    Letter.changeset(letter, %{})
  end
end
