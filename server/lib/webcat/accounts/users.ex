defmodule WebCAT.Accounts.Users do
  @moduledoc """
  Helper methods for the user collection
  """
  use Anaphora

  alias WebCAT.Repo
  alias WebCAT.Accounts.{User, PasswordReset, Confirmation, Notification}
  alias WebCAT.Rotations.{Classroom, RotationGroup}
  alias Comeonin.Pbkdf2
  alias Ecto.Changeset
  alias Ecto.Multi
  import Ecto.Query

  @doc """
  List users in the system
  """
  @spec list(Keyword.t()) :: [User.t()]
  def list(options \\ []) do
    users =
      User
      |> limit(^Keyword.get(options, :limit, 25))
      |> offset(^Keyword.get(options, :offset, 0))
      |> Repo.all()

    {:ok, users}
  end

  @doc """
  Get a user by its id
  """
  @spec get(integer()) :: {:ok, User.t()} | {:error, any}
  def get(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
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
    |> Multi.run(:confirmation, fn %{user: user} ->
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
  Update a user by their `user_id`
  """
  @spec update(integer, map()) :: {:ok, User.t()} | {:error, any}
  def update(user_id, update) do
    with {:ok, user} <- get(user_id) do
      user
      |> User.changeset(update)
      |> Repo.update()
    end
  end

  @doc """
  Delete a user by their `user_id`
  """
  @spec delete(integer) :: {:ok, User.t()} | {:error, any}
  def delete(user_id) do
    with {:ok, user} <- get(user_id) do
      Repo.delete(user)
    end
  end

  @doc """
  Login a user, returning the user if the authentication is successful
  """
  @spec login(String.t(), String.t()) :: {:ok, User.t()} | {:error, :unauthorized, String.t()}
  def login(email, password) do
    user =
      User
      |> where([u], u.email == ^email)
      |> Repo.one()
      |> check_password(password)

    case user do
      {:ok, _} -> user
      {:error, message} -> {:error, :unauthorized}
    end
  end

  @doc """
  Get all associated rotation groups for a user
  """
  @spec rotation_groups(integer, Keyword.t()) :: {:ok, [RotationGroup.t()]}
  def rotation_groups(user_id, options \\ []) do
    groups =
      RotationGroup
      |> where([g], g.instructor_id == ^user_id)
      |> limit(^Keyword.get(options, :limit, 25))
      |> offset(^Keyword.get(options, :offset, 0))
      |> order_by(desc: :inserted_at)
      |> Repo.all()

    {:ok, groups}
  end

  @doc """
  Get all associated notifications for a user
  """
  @spec notifications(integer, Keyword.t()) :: {:ok, [Notification.t()]}
  def notifications(user_id, options \\ []) do
    notifications =
      Notification
      |> where([n], n.user_id == ^user_id)
      |> limit(^Keyword.get(options, :limit, 25))
      |> offset(^Keyword.get(options, :offset, 0))
      |> order_by(desc: :inserted_at)
      |> Repo.all()

    {:ok, notifications}
  end

  @doc """
  Get all of the classrooms a user belongs to
  """
  @spec classrooms(integer) :: {:ok, [Classroom.t()]}
  def classrooms(user_id, options \\ []) do
    classrooms =
      Classroom
      |> join(:inner, [c], uc in "user_classrooms", uc.classroom_id == c.id)
      |> where([_, uc], uc.user_id == ^user_id)
      |> limit(^Keyword.get(options, :limit, 25))
      |> offset(^Keyword.get(options, :offset, 0))
      |> order_by([c, _], desc: c.inserted_at)
      |> select([c, _], c)
      |> Repo.all()

    {:ok, classrooms}
  end

  defp check_password(nil, _), do: {:error, "Incorrect username or password"}

  defp check_password(%User{} = user, password) do
    case Pbkdf2.checkpw(password, user.password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end
end
