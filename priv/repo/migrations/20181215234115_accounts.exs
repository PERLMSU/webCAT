defmodule WebCAT.Repo.Migrations.Accounts do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    extension("pgcrypto")
    enum("user_role", ~w(assistant admin))

    create table(:users) do
      add_req(:first_name, :text)
      add_req(:last_name, :text)
      add(:middle_name, :text)
      add_req(:email, :text)
      add_req(:username, :text)
      add_req(:password, :text)
      add(:nickname, :text)
      add(:bio, :text)
      add(:phone, :text)
      add(:city, :text)
      add(:state, :text)
      add(:country, :text)
      add(:birthday, :date)
      add_req(:active, :boolean, default: true)
      add_req(:role, :user_role, default: "assistant")

      timestamps()
    end

    create table(:confirmations) do
      add_req(:token, :text)
      add_req(:user_id, references(:users))
      add_req(:verified, :boolean, default: false)

      timestamps()
    end

    create table(:password_resets) do
      add_req(:token, :text)
      add_req(:user_id, references(:users))

      timestamps()
    end

    create(unique_index(:users, ~w(email)a))
    create(unique_index(:users, ~w(username)a))
    create(unique_index(:confirmations, ~w(token)a))
    create(unique_index(:password_resets, ~w(token)a))
  end
end
