defmodule WebCATWeb.UserController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.CRUD
  alias WebCAT.Accounts.{User, Users}

  action_fallback(WebCATWeb.FallbackController)

  @preload [rotation_groups: ~w(students)a, classrooms: ~w(semesters users)a, performer: ~w(roles)a]

  def index(conn, user, _params) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         users <- CRUD.list(User, preload: @preload) do
      render(conn, "index.html", user: user, selected: "users", data: users)
    end
  end

  def show(conn, auth_user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, user} <- CRUD.get(User, id, preload: @preload) do
      render(conn, "show.html", user: auth_user, selected: "users", data: user)
    end
  end

  def new(conn, auth_user, _params) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      conn
      |> render("new.html",
        user: auth_user,
        changeset: User.changeset(%User{}),
        selected: "users"
      )
    end
  end

  def create(conn, auth_user, %{"user" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case(Users.create(params)) do
        {:ok, created} ->
          conn
          |> put_flash(:info, "User created!")
          |> redirect(to: Routes.user_path(conn, :show, created.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html",
            user: auth_user,
            changeset: changeset,
            selected: "users"
          )
      end
    end
  end

  def edit(conn, auth_user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:ok, user} <- CRUD.get(User, id, preload: @preload),
         :ok <- is_authorized?() do
      render(conn, "edit.html",
        user: auth_user,
        selected: "users",
        changeset: User.changeset(user)
      )
    end
  end

  def update(conn, auth_user, %{"id" => id, "user" => update}) do
    permissions do
      has_role(:admin)
    end

    with {:ok, user} <- CRUD.get(User, id, preload: @preload),
         :ok <- is_authorized?() do
      case CRUD.update(User, user, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "User updated!")
          |> redirect(to: Routes.user_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: auth_user,
            selected: "users",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:ok, _} <- CRUD.get(User, id),
         :ok <- is_authorized?() do
      case CRUD.delete(User, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "User deleted successfully")
          |> redirect(to: Routes.user_path(conn, :index))

        {:error, _} ->
          conn
          |> put_flash(:error, "User deletion failed")
          |> redirect(to: Routes.user_path(conn, :index))
      end
    end
  end
end
