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
    PasswordCredential
    |> where([c], c.email == ^email)
    |> join(:left, [c], u in assoc(c, :user))
    |> select([_, u], u)
    |> Repo.one()
    |> case do
      %User{} = user -> {:ok, user}
      nil -> {:error, "Email not found"}
    end
  end

  @doc """
  Use supplied attributes to sign up a new user and send them a token to login via a supplied email address
  """
  @spec create(map(), String.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def create(attrs, email) do
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
        WebCAT.Email.confirmation(email, result.credential.token)
        |> WebCAT.Mailer.deliver_later()

        {:ok, result.user}

      {:error, _, changeset, %{}} ->
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
    |> where([c], c.email == ^email)
    |> join(:left, [c], u in assoc(c, :user))
    |> preload([_, u], user: u)
    |> Repo.one()
    |> check_password(password)
    |> case do
      {:ok, credential} -> {:ok, credential.user}
      {:error, _} = it -> it
    end
  end

  defp check_password(nil, _), do: {:error, "Incorrect email or password"}

  defp check_password(%PasswordCredential{password: hashed_password} = credential, password) do
    case Pbkdf2.checkpw(password, hashed_password) do
      true -> {:ok, credential}
      false -> {:error, "Incorrect email or password"}
    end
  end
end
