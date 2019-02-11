defmodule WebCATWeb.UserController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Accounts.{User, Users}

  action_fallback(WebCATWeb.FallbackController)

  @preload [rotation_groups: ~w(students)a, classrooms: ~w(semesters users)a]

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(User, :list, user),
         users <- CRUD.list(User) do
      render(conn, "index.html", user: user, selected: "users", data: users)
    end
  end

  def show(conn, %{"id" => id}) do
    auth_user = Auth.current_resource(conn)
    with {:ok, user} <- CRUD.get(User, id, preload: @preload),
         :ok <- Bodyguard.permit(User, :show, auth_user, user) do
      render(conn, "show.html", user: auth_user, selected: "users", data: user)
    end
  end

  def new(conn, _params) do
    auth_user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(User, :create, auth_user) do
      conn
      |> render("new.html",
        user: auth_user,
        changeset: User.create_changeset(%User{}),
        selected: "users"
      )
    end
  end

  def create(conn, %{"user" => params}) do
    auth_user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(User, :create, auth_user) do
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

  def edit(conn, %{"id" => id}) do
    auth_user = Auth.current_resource(conn)

    with {:ok, user} <- CRUD.get(User, id, preload: @preload),
         :ok <- Bodyguard.permit(User, :update, auth_user, user) do
      render(conn, "edit.html",
        user: auth_user,
        selected: "users",
        changeset: User.changeset(user)
      )
    end
  end

  def update(conn, %{"id" => id, "user" => update}) do
    auth_user = Auth.current_resource(conn)

    with {:ok, user} <- CRUD.get(User, id, preload: @preload),
         :ok <- Bodyguard.permit(User, :update, auth_user, user) do
      case CRUD.update(User, user, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "User updated!")
          |> redirect(to: Routes.user_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "users",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    auth_user = Auth.current_resource(conn)

    with {:ok, user} <- CRUD.get(User, id),
         :ok <- Bodyguard.permit(User, :delete, auth_user, user) do
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
