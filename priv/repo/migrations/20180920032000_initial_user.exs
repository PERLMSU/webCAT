defmodule WebCAT.Repo.Migrations.InitialUser do
  use Ecto.Migration

  alias WebCAT.Repo
  alias WebCAT.Accounts.User

  def change do
    Repo.insert!(User.create_changeset(%User{}, %{
      first_name: "Admin",
      last_name: "McAdmin",
      email: "wcat_admin@msu.edu",
      username: "admin",
      password: "password",
      bio: "This is the default administrative account. Change it's details as you please.",
      city: "East Lansing",
      state: "MI",
      country: "USA",
      active: true,
      role: "instructor",
    }))
  end
end
