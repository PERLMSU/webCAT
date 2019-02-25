defmodule WebCATWeb.ProfileController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.CRUD
  alias WebCAT.Accounts.{User, PasswordCredential}
  alias WebCAT.Repo

  @preload [
    classrooms: ~w(semesters users)a,
    sections: ~w(rotations users)a,
    rotation_groups: ~w(users)a
  ]

  def show(conn, user, _params) do
    permissions do
      has_role(:admin)
      has_role(:assisstant)
    end

    with :ok <- is_authorized?() do
      render(conn, "show.html",
        user: Repo.preload(user, @preload),
        selected: nil
      )
    end
  end

  def edit(conn, user, _params) do
    permissions do
      has_role(:admin)
      has_role(:assisstant)
    end

    with :ok <- is_authorized?() do
      render(conn, "edit.html", user: user, selected: nil, changeset: User.changeset(user))
    end
  end

  def update(conn, user, %{"user" => update}) do
    permissions do
      has_role(:admin)
      has_role(:assisstant)
    end

    with :ok <- is_authorized?() do
      case CRUD.update(User, user, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Profile updated!")
          |> redirect(to: Routes.profile_path(conn, :show))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: nil,
            changeset: changeset
          )
      end
    end
  end

  def edit_password(conn, user, _params) do
    permissions do
      has_role(:admin)
      has_role(:assisstant)
    end

    with :ok <- is_authorized?(),
         credential <- Repo.get_by(PasswordCredential, user_id: user.id) do
      render(conn, "edit_password.html",
        user: user,
        selected: nil,
        changeset: PasswordCredential.changeset(credential)
      )
    end
  end

  def update_password(conn, user, %{"password_credential" => update}) do
    permissions do
      has_role(:admin)
      has_role(:assisstant)
    end

    with :ok <- is_authorized?(),
         credential <- Repo.get_by(PasswordCredential, user_id: user.id) do
      case Repo.update(PasswordCredential.changeset(credential, update)) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Password updated, please login again!")
          |> Auth.sign_out()
          |> redirect(to: Routes.login_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit_password.html",
            user: user,
            selected: nil,
            changeset: changeset
          )
      end
    end
  end
end
