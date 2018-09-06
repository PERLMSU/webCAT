defmodule WebCAT.Accounts.PasswordResets do
  @moduledoc """
  Utility functions for working with password resets
  """

  use Anaphora
  alias WebCAT.Repo
  alias WebCAT.Accounts.{PasswordReset, User, Users}
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
        |> PasswordReset.changeset(%{user_id: user.id, token: PasswordReset.gen_token()})
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
      %PasswordReset{} = reset -> {:ok, reset}
      nil -> {:error, :not_found}
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
        # Delete if reset older than 24 hours
        if Timex.before?(reset.inserted_at, Timex.shift(Timex.now(), days: -1)) do
          Repo.delete(reset)
          {:error, :not_found}
        else
          with {:ok, user} <- Users.get(reset.user_id) do
            user_changeset = User.changeset(user, %{password: Pbkdf2.hashpwsalt(new_password)})

            Multi.new()
            |> Multi.update(:user, user_changeset)
            |> Multi.delete(:reset, reset)
            |> Repo.transaction()
            |> case do
              {:ok, result} -> {:ok, result.user}
              {:error, _, changeset, %{}} -> {:error, changeset}
            end
          end
        end

      nil ->
        {:error, :not_found}
    end
  end
end
