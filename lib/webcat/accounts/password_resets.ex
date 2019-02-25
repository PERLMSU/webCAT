defmodule WebCAT.Accounts.PasswordResets do
  @moduledoc """
  Utility functions for working with password resets
  """

  use Anaphora
  alias WebCAT.Repo
  alias WebCAT.Accounts.{PasswordReset, User, Users, PasswordCredential}
  alias Comeonin.Pbkdf2
  alias Ecto.Multi

  @doc """
  Start the password reset process
  """
  @spec start_reset(String.t()) :: {:ok, PasswordReset.t()} | {:error, any}
  def start_reset(email) when is_binary(email) do
    with {:ok, user} <- Users.by_email(email) do
      # Delete an existing reset if it exists
      aif(Repo.get_by(PasswordReset, user_id: user.id), do: Repo.delete(it))

      inserted =
        %PasswordReset{}
        |> PasswordReset.changeset(%{user_id: user.id, expire: Timex.shift(Timex.now(), days: 1)})
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

  @spec get(any()) :: {:error, :not_found} | {:ok, WebCAT.Accounts.PasswordReset.t()}
  def get(token) when is_binary(token) do
    case Repo.get_by(PasswordReset, token: token) do
      %PasswordReset{} = reset ->
        # Delete if reset older than 24 hours
        if Timex.after?(Timex.now(), reset.expire) do
          Repo.delete(reset)
          {:error, :not_found}
        else
          {:ok, reset}
        end

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Reset a user's password
  """
  @spec finish_reset(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, Changeset.t()} | {:error, any}
  def finish_reset(token, new_password) when is_binary(token) and is_binary(new_password) do
    case Repo.get_by(PasswordReset, token: token) do
      %PasswordReset{} = reset ->
        case Repo.get_by(PasswordCredential, user_id: reset.user_id) do
          nil ->
            nil

          credential ->
            changeset = PasswordCredential.changeset(credential, %{password: new_password})

            Multi.new()
            |> Multi.update(:credential, changeset)
            |> Multi.delete(:reset, reset)
            |> Repo.transaction()
            |> case do
              {:ok, result} -> {:ok, Repo.get(User, result.credential.user_id)}
              {:error, _, changeset, %{}} -> {:error, changeset}
            end
        end

      nil ->
        {:error, :not_found}
    end
  end
end
