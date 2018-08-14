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
  @spec get(Keyword.t()) :: [User.t()]
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
  @spec get(integer()) :: {:ok, User.t()} | {:error, :not_found, String.t()}
  def get(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found, "user #{id} not found"}
    end
  end

  @doc """
  Update a user by their `user_id`
  """
  @spec update(integer, map()) ::
          {:ok, User.t()} | {:error, :not_found, String.t()} | {:error, Changeset.t()}
  def update(user_id, update) do
    with {:ok, user} <- get(user_id) do
      user
      |> User.changeset(update)
      |> Repo.update()
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
      {:error, message} -> {:error, :unauthorized, message}
    end
  end

  @doc """
  Use supplied attributes to sign up a new user
  """
  @spec signup(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def signup(attrs) do
    multi =
      Multi.new()
      |> Multi.insert(:user, User.create_changeset(%User{}, attrs))
      |> Multi.run(:confirmation, fn %{user: user} ->
        %Confirmation{}
        |> Confirmation.changeset(%{user_id: user.id, token: Confirmation.gen_token()})
        |> Repo.insert()
      end)

    case Repo.transaction(multi) do
      {:ok, result} ->
        WebCAT.Email.confirmation(result.user.email, result.confirmation.token)
        |> WebCAT.Mailer.deliver_later()

        {:ok, result.user}

      {:error, _, changeset, %{}} ->
        {:error, changeset}
    end
  end

  @doc """
  Get all associated rotation groups for a user
  """
  @spec rotation_groups(integer) :: [RotationGroup.t()]
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
  @spec classrooms(integer) :: [Classroom.t()]
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

  @doc """
  Confirm a user based on a token
  """
  @spec confirm(String.t()) :: {:ok, Confirmation.t()} | {:error, atom, String.t()}
  def confirm(token) do
    case Repo.get_by(Confirmation, token: token) do
      %Confirmation{} = confirmation ->
        if confirmation.verified do
          {:error, :bad_request, "email already verified"}
        else
          confirmation
          |> Confirmation.changeset(%{verified: true})
          |> Repo.update()
        end

      nil ->
        {:error, :not_found, "confirmation token not found"}
    end
  end

  @doc """
  Start the password reset process
  """
  @spec start_reset(integer) :: {:ok, PasswordReset.t()} | {:error, Changeset.t()}
  def start_reset(user_id) do
    # Delete an existing reset if it exists
    aif(Repo.get_by(PasswordReset, user_id: user_id), do: Repo.delete(it))

    with {:ok, user} <- get(user_id) do
      inserted =
        %PasswordReset{}
        |> PasswordReset.changeset(%{user_id: user_id, token: PasswordReset.gen_token()})
        |> Repo.insert()

      case inserted do
        {:ok, reset} ->
          WebCAT.Email.password_reset(user.email, reset.token)
          |> WebCAT.Mailer.deliver_later()

          {:ok, reset}

        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end

  @doc """
  Reset a user's password
  """
  @spec reset(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, Changeset.t()} | {:error, :not_found, String.t()}
  def reset(token, new_password) do
    case Repo.get_by(PasswordReset, token: token) do
      %PasswordReset{} = reset ->
        # Delete if reset older than 24 hours
        if Timex.before?(reset.inserted_at, Timex.shift(Timex.now(), days: -1)) do
          Repo.delete(reset)
          {:error, :not_found, "password reset token not found"}
        else
          with {:ok, user} <- get(reset.user_id) do
            user_changeset = User.changeset(user, %{password: Pbkdf2.hashpwsalt(new_password)})

            multi =
              Multi.new()
              |> Multi.update(:user, user_changeset)
              |> Multi.delete(:reset, reset)

            case Repo.transaction(multi) do
              {:ok, result} -> {:ok, result.user}
              {:error, _, changeset, %{}} -> {:error, changeset}
            end
          end
        end

      nil ->
        {:error, :not_found, "password reset token not found"}
    end
  end

  defp check_password(nil, _), do: {:error, "Incorrect username or password"}

  defp check_password(%User{} = user, password) do
    case Pbkdf2.checkpw(password, user.password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end
end
