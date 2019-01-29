defmodule WebCAT.Accounts.Users do
  @moduledoc """
  Helper methods for the user collection
  """
  use Anaphora

  alias WebCAT.Repo
  alias WebCAT.Accounts.{User, Confirmation, Notification}
  alias WebCAT.Rotations.{Classroom, RotationGroup, Section}
  alias Comeonin.Pbkdf2
  alias Ecto.Changeset
  alias Ecto.Multi
  import Ecto.Query

  def list(options \\ []) do
    User
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :email)
    |> Repo.all()
  end

  @doc """
  Get a user by their email
  """
  @spec by_email(String.t()) :: {:ok, User.t()} | {:error, any}
  def by_email(email) do
    case Repo.get_by(User, email: email) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Use supplied attributes to sign up a new user
  """
  @spec create(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def create(attrs) do
    Multi.new()
    |> Multi.insert(:user, User.create_changeset(%User{}, attrs))
    |> Multi.run(:confirmation, fn _repo, %{user: user} ->
      %Confirmation{}
      |> Confirmation.changeset(%{user_id: user.id, token: Confirmation.gen_token()})
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        WebCAT.Email.confirmation(result.user.email, result.confirmation.token)
        |> WebCAT.Mailer.deliver_later()

        {:ok, result.user}

      {:error, _, changeset, %{}} ->
        {:error, changeset}
    end
  end

  @doc """
  Login a user, returning the user if the authentication is successful
  """
  @spec login(String.t(), String.t()) :: {:ok, User.t()} | {:error, :unauthorized}
  def login(email, password) do
    User
    |> where([u], u.email == ^email)
    |> Repo.one()
    |> check_password(password)
    |> acase do
      {:ok, _} -> it
      {:error, _} -> {:error, :unauthorized}
    end
  end

  @doc """
  Get all associated rotation groups for a user
  assistants only get rotation groups they're assigned to
  """
  @spec rotation_groups(integer) :: [RotationGroup.t()]
  def rotation_groups(user) do
    case user.role do
      "assistant" ->
        RotationGroup
        |> join(:inner, [rg], u in assoc(rg, :users))
        |> join(:inner, [rg], r in assoc(rg, :rotation))
        |> where([_rg, u], u.id == ^user.id)
        |> group_by([rg], rg.rotation_id)
        |> preload([_rg, _u, r], rotation: r)
        |> order_by([_rg, _u, r], desc: r.start_date)
        |> select([rg], rg)
        |> Repo.all()

      "instructor" ->
        Section
        |> join(:inner, [s], u in assoc(s, :users))
        |> join(:inner, [s], r in assoc(s, :rotations))
        |> join(:inner, [_s, _u, r], r in assoc(r, :rotation_groups))
        |> where([_s, u], u.id == ^user.id)
        |> group_by([_s, _u, _r, rg], rg.rotation_id)
        |> order_by([_s, _u, r], desc: r.start_date)
        |> select([_s, _u, _r, rg], rg)
        |> Repo.all()

      "admin" ->
        RotationGroup
        |> join(:inner, [rg], c in assoc(rg, :classrooms))
        |> join(:inner, [_rg, c], u in assoc(c, :users))
        |> join(:inner, [_rg, c, _u], s in assoc(c, :sections))
        |> join(:inner, [_rg, _c, _u, s], r in assoc(s, :rotations))
        |> join(:inner, [_rg, _c, _u, _s, r], r in assoc(r, :rotation_groups))
        |> where([_s, u], u.id == ^user.id)
        |> Repo.all()
    end

    RotationGroup
    |> join(:inner, [rg], u in assoc(rg, :users))
    |> join(:inner, [rg], s in assoc(rg, :students))
    |> join(:inner, [rg], o in assoc(rg, :observations))
    |> join(:inner, [rg], r in assoc(rg, :rotation))
    |> where([_, u], u.id == ^user.id)
    |> order_by([_, _, _, _, r], desc: r.number)
    |> preload([_, _, s, o, r], students: s, observations: o, rotation: r)
    |> Repo.all()
  end

  @doc """
  Get all associated notifications for a user
  """
  @spec notifications(integer, Keyword.t()) :: [Notification.t()]
  def notifications(user_id, options \\ []) do
    Notification
    |> where([n], n.user_id == ^user_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Get all of the classrooms a user belongs to
  """
  @spec classrooms(integer) :: [Classroom.t()]
  def classrooms(user_id, options \\ []) do
    Classroom
    |> join(:inner, [c], uc in "user_classrooms", on: uc.classroom_id == c.id)
    |> where([_, uc], uc.user_id == ^user_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by([c, _], desc: c.inserted_at)
    |> select([c, _], c)
    |> Repo.all()
  end

  defp check_password(nil, _), do: {:error, "Incorrect username or password"}

  defp check_password(%User{} = user, password) do
    case Pbkdf2.checkpw(password, user.password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end
end
