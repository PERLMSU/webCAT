defmodule WebCAT.Accounts.PasswordReset do
  @moduledoc """
  Allows the user to reset their password using a one-time use token
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "password_resets" do
    field(:token, :string)
    field(:expire, :utc_datetime)

    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  @required ~w(token expire user_id)a

  @doc """
  Build a changeset for a password reset
  """
  def changeset(reset, attrs \\ %{}) do
    reset
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token)
    |> put_token()
  end

  defp put_token(%Ecto.Changeset{valid?: true} = changeset) do
    change(changeset, token: Base.encode32(:crypto.strong_rand_bytes(32)))
  end

  defp put_token(changeset), do: changeset
end
