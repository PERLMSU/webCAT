defmodule WebCAT.Accounts.PasswordReset do
  @moduledoc """
  Allows the user to reset their password using a one-time use token
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "password_resets" do
    field(:token, :string, primary_key: true)
    field(:expire, :utc_datetime)

    belongs_to(:user, WebCAT.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  @required ~w(expire user_id)a
  @optional ~w(token)a

  @doc """
  Build a changeset for a password reset
  """
  def changeset(reset, attrs \\ %{}) do
    reset
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token)
    |> put_token()
  end

  defp put_token(%Ecto.Changeset{valid?: true, data: %{token: nil}} = changeset) do
    change(changeset, token: Base.encode32(:crypto.strong_rand_bytes(32)))
  end

  defp put_token(changeset), do: changeset
end
