defmodule WebCAT.Accounts.PasswordCredential do
  @moduledoc """
  Allows a user to login to their account using a typical email-password combination
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Pbkdf2

  @primary_key false
  schema "password_credentials" do
    field(:email, :string)
    field(:password, :string)

    belongs_to(:user, WebCAT.Accounts.User)

    timestamps()
  end

  @required ~w(email password user_id)a

  @doc """
  Build a changeset for a credential
  """
  def changeset(credential, attrs \\ %{}) do
    credential
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Pbkdf2.hashpwsalt(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
