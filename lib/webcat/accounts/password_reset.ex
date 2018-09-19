defmodule WebCAT.Accounts.PasswordReset do
  @moduledoc """
  Schema for password reset tokens
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "password_resets" do
    field(:token, :string)

    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  def gen_token do
    :crypto.strong_rand_bytes(32)
    |> Base.encode32()
  end

  @doc """
  Build a changeset for a password reset
  """
  def changeset(reset, attrs \\ %{}) do
    reset
    |> cast(attrs, ~w(token user_id)a)
    |> validate_required(~w(token user_id)a)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token)
  end
end
