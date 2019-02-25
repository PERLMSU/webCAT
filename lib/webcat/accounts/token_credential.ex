defmodule WebCAT.Accounts.TokenCredential do
  @moduledoc """
  Allows a user to login to their account limited time token
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "token_credentials" do
    field(:token, :string,  primary_key: true)
    field(:expire, :utc_datetime)

    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  @required ~w(expire user_id)a
  @optional ~w(token)a

  @doc """
  Build a changeset for a credential
  """
  def changeset(credential, attrs \\ %{}) do
    credential
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> put_token()
  end

  defp put_token(%Ecto.Changeset{valid?: true, data: %{token: nil}} = changeset) do
    change(changeset, token: Base.encode32(:crypto.strong_rand_bytes(32)))
  end

  defp put_token(changeset), do: changeset
end
