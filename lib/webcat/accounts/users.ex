defmodule WebCAT.Accounts.Users do
  @moduledoc """
  Helper methods for the user collection
  """
  alias WebCAT.Repo
  alias WebCAT.Accounts.{User, TokenCredential, PasswordCredential}
  alias Comeonin.Pbkdf2
  alias Ecto.Changeset
  alias Ecto.Multi
  import Ecto.Query

  @doc """
  Get a user by their email if they have one associated
  """
  @spec by_email(String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def by_email(email) do
    User
    |> where([u], u.email == ^email)
    |> Repo.one()
    |> case do
      %User{} = user -> {:ok, user}
      nil -> {:error, "Email not found"}
    end
  end

  @doc """
  Use supplied attributes to sign up a new user and send them a token to login via a supplied email address
  """
  @spec create(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def create(attrs) do
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, attrs))
    |> Multi.run(:credential, fn _repo, %{user: user} ->
      %TokenCredential{}
      |> TokenCredential.changeset(%{user_id: user.id, expire: Timex.shift(Timex.now(), days: 1)})
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        WebCATWeb.Email.confirmation(result.user.email, result.credential.token)
        |> WebCAT.Mailer.deliver_later()

        {:ok, result.user}

      {:error, _, changeset, %{}} ->
        {:error, changeset}
    end
  end

  def send_confirmation(user) do
    %TokenCredential{}
    |> TokenCredential.changeset(%{user_id: user.id, expire: Timex.shift(Timex.now(), days: 1)})
    |> Repo.insert()
    |> case do
      {:ok, credential} ->
        WebCATWeb.Email.confirmation(user.email, credential.token)
        |> WebCAT.Mailer.deliver_later()

        :ok

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Login a user using a token credential
  """
  @spec login(String.t()) :: {:ok, User.t()} | {:error}
  def login(token) do
    TokenCredential
    |> where([c], c.token == ^token)
    |> join(:left, [c], u in assoc(c, :user))
    |> preload([_, u], user: u)
    |> Repo.one()
    |> case do
      %TokenCredential{} = credential ->
        if Timex.after?(Timex.now(), credential.expire) do
          Repo.delete(credential)
          {:error, "Token not found or expired"}
        else
          {:ok, credential.user}
        end

      nil ->
        {:error, "Token not found or expired"}
    end
  end

  @doc """
  Login a user using an email-password credential
  """
  @spec login(String.t(), String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def login(email, password) do
    PasswordCredential
    |> join(:left, [c], u in assoc(c, :user))
    |> where([_, u], u.email == ^email)
    |> preload([_, u], user: u)
    |> Repo.one()
    |> check_password(password)
    |> case do
      {:ok, credential} ->
        {:ok, credential.user}

      {:error, _} = it ->
        it
    end
  end

  @doc """
  Get all users with a specific role
  """
  def with_role(role) do
    User
    |> join(:left, [u], p in assoc(u, :performer))
    |> join(:left, [_, p], r in assoc(p, :roles))
    |> where([_, _, role], role.name == ^role)
    |> preload([_, p, r], performer: {p, roles: r})
    |> Repo.all()
  end

  defp check_password(nil, _), do: {:error, "Incorrect email or password"}

  defp check_password(%PasswordCredential{password: hashed_password} = credential, password) do
    case Pbkdf2.checkpw(password, hashed_password) do
      true -> {:ok, credential}
      false -> {:error, "Incorrect email or password"}
    end
  end
end
