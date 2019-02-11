defmodule WebCAT.Repo.Migrations.Accounts do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    extension("pgcrypto")

    create table(:users) do
      add_req(:first_name, :text)
      add_req(:last_name, :text)
      add(:middle_name, :text)
      add(:nickname, :text)
      add_req(:active, :boolean, default: true)

      timestamps()
    end

    create table(:password_credentials, primary_key: false) do
      add_req(:email, :text, primary_key: true)
      add_req(:password, :text)
      add_req(:user_id, references(:users))

      timestamps()
    end

    create table(:token_credentials, primary_key: false) do
      add_req(:token, :text, primary_key: true)
      add_req(:expire, :utc_datetime)
      add_req(:user_id, references(:users))

      timestamps()
    end

    create table(:password_resets, primary_key: false) do
      add_req(:token, :text, primary_key: true)
      add_req(:expire, :utc_datetime)
      add_req(:user_id, references(:users))

      timestamps()
    end

    create table(:groups) do
      add_req(:name, :text)

      timestamps()
    end

    create table(:user_groups, primary_key: false) do
      add_req(:user_id, references(:users, on_delete: :delete_all), primary_key: true)
      add_req(:group_id, references(:groups, on_delete: :delete_all), primary_key: true)
    end

    create(unique_index(:groups, ~w(name)a))
  end
end
