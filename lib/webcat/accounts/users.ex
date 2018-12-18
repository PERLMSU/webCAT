defmodule WebCAT.Accounts.Users do
  @moduledoc """
  Helper methods for the user collection
  """
  use Anaphora

  alias WebCAT.Repo
  alias WebCAT.Accounts.{User, Confirmation, Notification}
  alias WebCAT.Rotations.{Classroom, RotationGroup}
  alias Comeonin.Pbkdf2
  alias WebCAT.CRUD
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
  """
  @spec rotation_groups(integer, Keyword.t()) :: [RotationGroup.t()]
  def rotation_groups(user_id, options \\ []) do

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
