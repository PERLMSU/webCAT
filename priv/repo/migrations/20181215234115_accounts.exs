defmodule WebCAT.Repo.Migrations.Accounts do
  use Ecto.Migration
  import WebCAT.Repo.Helpers

  def change do
    create table(:users) do
      add_req(:email, :text)
      add_req(:first_name, :text)
      add_req(:last_name, :text)
      add(:middle_name, :text)
      add(:nickname, :text)
      add_req(:active, :boolean, default: true)

      timestamps(type: :timestamptz)
    end

    create table(:password_credentials, primary_key: false) do
      add_req(:user_id, references(:users), primary_key: true)
      add_req(:password, :text)

      timestamps(type: :timestamptz)
    end

    create table(:token_credentials, primary_key: false) do
      add_req(:token, :text, primary_key: true)
      add_req(:expire, :utc_datetime)
      add_req(:user_id, references(:users))

      timestamps(type: :timestamptz)
    end

    create table(:password_resets, primary_key: false) do
      add_req(:user_id, references(:users))
      add_req(:token, :text, primary_key: true)
      add_req(:expire, :utc_datetime)

      timestamps(type: :timestamptz)
    end

    create(unique_index(:users, ~w(email)a))
  end
end
