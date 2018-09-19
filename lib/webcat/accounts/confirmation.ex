defmodule WebCAT.Accounts.Confirmation do
  @moduledoc """
  Schema for user confirmations
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "confirmations" do
    field(:token, :string)
    field(:verified, :boolean)

    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  def gen_token do
    :crypto.strong_rand_bytes(32)
    |> Base.encode32()
  end

  @doc """
  Build a changeset for a confirmation
  """
  def changeset(confirmation, attrs \\ %{}) do
    confirmation
    |> cast(attrs, ~w(token user_id verified)a)
    |> validate_required(~w(token user_id)a)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token)
  end
end
