defmodule WebCAT.Accounts.PasswordCredential do
  @moduledoc """
  Allows a user to login to their account using a typical email-password combination
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Pbkdf2

  @primary_key false
  schema "password_credentials" do
    field(:password, :string)

    belongs_to(:user, WebCAT.Accounts.User, primary_key: true)

    # To support changing passwords through changesets
    field(:current_password, :string, virtual: true)
    field(:new_password, :string, virtual: true)
    field(:confirm_new_password, :string, virtual: true)

    timestamps()
  end

  @required ~w(password user_id)a
  @optional ~w(current_password new_password confirm_new_password)a

  @doc """
  Build a changeset for a credential
  """
  def changeset(credential, attrs \\ %{}) do
    credential
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> validate_password_change()
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    case password do
      # If already encrypted
      "$pbkdf2-sha512$" <> _ -> changeset
      _ -> change(changeset, password: Pbkdf2.hashpwsalt(password))
    end
  end

  defp put_pass_hash(changeset), do: changeset

  defp validate_password_change(changeset) do
    with {_, password} <- fetch_field(changeset, :password),
         {_, current_password} <- fetch_change(changeset, :current_password),
         {_, new_password} <- fetch_change(changeset, :new_password),
         {_, confirm_new_password} <- fetch_change(changeset, :confirm_new_password) do
      cond do
        is_nil(current_password) and is_nil(new_password) and is_nil(confirm_new_password) ->
          changeset

        Pbkdf2.checkpw(current_password, password) != true ->
          add_error(changeset, :current_password, "Incorrect password")

        current_password == new_password ->
          add_error(changeset, :new_password, "New password and old password are the same")

        new_password != confirm_new_password ->
          add_error(changeset, :confirm_new_password, "New passwords don't match")

        true ->
          changeset
          |> delete_change(:current_password)
          |> delete_change(:new_password)
          |> delete_change(:confirm_new_password)
          |> put_change(:password, new_password)
      end
    else
      :error -> changeset
    end
  end
end
