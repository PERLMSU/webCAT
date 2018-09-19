defmodule WebCATWeb.UserController do
  @moduledoc """
  Handle user actions
  """

  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Accounts.{User, Users}
  alias WebCATWeb.{UserView, NotificationView, ClassroomView, RotationGroupView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Accounts, :list_users, user),
         users <- CRUD.list(User, limit: limit, offset: offset) do
      conn
      |> render(UserView, "list.json", users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_user} <- CRUD.get(User, id),
         :ok <- Bodyguard.permit(WebCAT.Accounts, :show_user, user, subject_user) do
      conn
      |> render(UserView, "show.json", user: subject_user)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Accounts, :create_user, user),
         {:ok, created} <- Users.create(params) do
      conn
      |> put_status(:created)
      |> render(UserView, "show.json", user: created)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_user} <- CRUD.get(User, id),
         :ok <- Bodyguard.permit(WebCAT.Accounts, :update_user, user, subject_user),
         {:ok, updated} <- CRUD.update(User, subject_user.id, Map.drop(params, ~w(id))) do
      conn
      |> render(UserView, "show.json", user: updated)
    end
  end

  def notifications(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_user} <- CRUD.get(User, id),
         :ok <- Bodyguard.permit(WebCAT.Accounts, :list_notifications, user, subject_user),
         notifications <- Users.notifications(subject_user.id, limit: limit, offset: offset) do
      conn
      |> render(NotificationView, "list.json", notifications: notifications)
    end
  end

  def classrooms(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_user} <- CRUD.get(User, id),
         :ok <- Bodyguard.permit(WebCAT.Accounts, :list_classrooms, user, subject_user),
         classrooms <- Users.classrooms(subject_user.id, limit: limit, offset: offset) do
      conn
      |> render(ClassroomView, "list.json", classrooms: classrooms)
    end
  end

  def rotation_groups(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_user} <- CRUD.get(User, id),
         :ok <- Bodyguard.permit(WebCAT.Accounts, :list_rotation_groups, user, subject_user),
         groups <- Users.rotation_groups(subject_user.id, limit: limit, offset: offset) do
      conn
      |> render(RotationGroupView, "list.json", rotation_groups: groups)
    end
  end
end
