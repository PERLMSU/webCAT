defmodule WebCATWeb.CRUDController do
  @moduledoc """
  Controller logic for resources we want to do CRUD operations on
  """
  use WebCATWeb, :controller

  alias WebCAT.Dashboardable
  alias WebCAT.CRUD
  alias WebCAT.Accounts.User
  alias WebCAT.Feedback.Category
  alias WebCAT.Rotations.{Classroom, RotationGroup, Rotation, Semester, Student}

  action_fallback(WebCATWeb.FallbackController)

  @resources ~w(categories classrooms rotation_groups rotations semesters students users)

  def index(conn, %{"resource" => resource}) when resource in @resources do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    {module, data} =
      case resource do
        "categories" ->
          with :ok <- Bodyguard.permit(Category, :list_categories, user),
               do: {Category, CRUD.list(Category)}

        "classrooms" ->
          with :ok <- Bodyguard.permit(Classroom, :list_classrooms, user),
               do: {Classroom, CRUD.list(Classroom)}

        "rotation_groups" ->
          with :ok <- Bodyguard.permit(RotationGroup, :list_rotation_groups, user),
               do: {RotationGroup, CRUD.list(RotationGroup)}

        "rotations" ->
          with :ok <- Bodyguard.permit(Rotation, :list_rotations, user),
               do: {Rotation, CRUD.list(Rotation)}

        "semesters" ->
          with :ok <- Bodyguard.permit(Semester, :list_semesters, user),
               do: {Semester, CRUD.list(Semester)}

        "students" ->
          with :ok <- Bodyguard.permit(Student, :list_student, user),
               do: {Student, CRUD.list(Student)}

        "users" ->
          with :ok <- Bodyguard.permit(User, :list_users, user), do: {User, CRUD.list(User)}
      end

    case data do
      :error -> {:error, :not_authorized}
      _ -> render(conn, "index.html", user: user, data: data, module: module)
    end
  end

  def show(conn, %{"resource" => resource, "id" => id}) when resource in @resources do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    data =
      case resource do
        "categories" ->
          with :ok <- Bodyguard.permit(Category, :show_category, user), do: CRUD.get(Category, id)

        "classrooms" ->
          with :ok <- Bodyguard.permit(Classroom, :show_classroom, user),
               do: CRUD.get(Classroom, id)

        "rotation_groups" ->
          with :ok <- Bodyguard.permit(RotationGroup, :show_rotation_group, user),
               do: CRUD.get(RotationGroup, id)

        "rotations" ->
          with :ok <- Bodyguard.permit(Rotation, :show_rotation, user), do: CRUD.get(Rotation, id)

        "semesters" ->
          with :ok <- Bodyguard.permit(Semester, :show_semester, user), do: CRUD.get(Semester, id)

        "students" ->
          with :ok <- Bodyguard.permit(Student, :show_student, user), do: CRUD.get(Student, id)

        "users" ->
          with :ok <- Bodyguard.permit(User, :show_user, user), do: CRUD.get(User, id)
      end

    case data do
      :error -> {:error, :not_authorized}
      nil -> {:error, :not_found}
      _ -> render(conn, "show.html", user: user, data: data)
    end
  end

  def new(conn, %{"resource" => resource}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    changeset =
      case resource do
        "categories" ->
          with :ok <- Bodyguard.permit(Category, :create_category, user),
               do: Category.changeset(%Category{})

        "classrooms" ->
          with :ok <- Bodyguard.permit(Classroom, :create_classroom, user),
               do: Classroom.changeset(%Classroom{})

        "rotation_groups" ->
          with :ok <- Bodyguard.permit(RotationGroup, :create_rotation_group, user),
               do: RotationGroup.changeset(%RotationGroup{})

        "rotations" ->
          with :ok <- Bodyguard.permit(Rotation, :create_rotation, user),
               do: Rotation.changeset(%Rotation{})

        "semesters" ->
          with :ok <- Bodyguard.permit(Semester, :create_semester, user),
               do: Semester.changeset(%Semester{})

        "students" ->
          with :ok <- Bodyguard.permit(Student, :create_student, user),
               do: Student.changeset(%Student{})

        "users" ->
          with :ok <- Bodyguard.permit(User, :create_user, user), do: User.changeset(%User{})
      end

    case changeset do
      :error -> {:error, :not_authorized}
      _ -> render(conn, "form.html", user: user, changeset: changeset)
    end
  end

  def create(conn, %{"resource" => resource} = assigns) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    {module, params} =
      case resource do
        "categories" ->
          with :ok <- Bodyguard.permit(Category, :create_category, user),
               do: {Category, Map.get(assigns, "category")}

        "classrooms" ->
          with :ok <- Bodyguard.permit(Classroom, :create_classroom, user),
               do: {Category, Map.get(assigns, "classroom")}

        "rotation_groups" ->
          with :ok <- Bodyguard.permit(RotationGroup, :create_rotation_group, user),
               do: {RotationGroup, Map.get(assigns, "rotation_group")}

        "rotations" ->
          with :ok <- Bodyguard.permit(Rotation, :create_rotation, user),
               do: {Rotation, Map.get(assigns, "rotation")}

        "semesters" ->
          with :ok <- Bodyguard.permit(Semester, :create_semester, user),
               do: {Semester, Map.get(assigns, "semester")}

        "students" ->
          with :ok <- Bodyguard.permit(Student, :create_student, user),
               do: {Student, Map.get(assigns, "student")}

        "users" ->
          with :ok <- Bodyguard.permit(User, :create_user, user),
               do: {User, Map.get(assigns, "user")}
      end

    case params do
      nil ->
        {:error, :bad_request}

      %{} ->
        case CRUD.create(module, params) do
          {:ok, data} ->
            conn
            |> put_flash(
              :info,
              ~s(#{module |> to_string |> String.split(".") |> List.last()} #{
                Dashboardable.title_for(module, data)
              } created!)
            )
            |> redirect(to: Routes.crud_path(conn, :index, module.__schema__(:source)))


          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "form.html", changeset: changeset, user: user)
        end
    end
  end

  def edit(conn, %{"resource" => resource, "id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    changeset =
      case resource do
        "categories" ->
          with :ok <- Bodyguard.permit(Category, :create_category, user),
               {:ok, category} <- CRUD.get(Category, id),
               do: Category.changeset(category)

        "classrooms" ->
          with :ok <- Bodyguard.permit(Classroom, :create_classroom, user),
               {:ok, classroom} <- CRUD.get(Classroom, id),
               do: Classroom.changeset(classroom)

        "rotation_groups" ->
          with :ok <- Bodyguard.permit(RotationGroup, :create_rotation_group, user),
               {:ok, rotation_group} <- CRUD.get(RotationGroup, id),
               do: RotationGroup.changeset(rotation_group)

        "rotations" ->
          with :ok <- Bodyguard.permit(Rotation, :create_rotation, user),
               {:ok, rotation} <- CRUD.get(Rotation, id),
               do: Rotation.changeset(rotation)

        "semesters" ->
          with :ok <- Bodyguard.permit(Semester, :create_semester, user),
               {:ok, semester} <- CRUD.get(Semester, id),
               do: Semester.changeset(semester)

        "students" ->
          with :ok <- Bodyguard.permit(Student, :create_student, user),
               {:ok, student} <- CRUD.get(Student, id),
               do: Student.changeset(student)

        "users" ->
          with :ok <- Bodyguard.permit(User, :create_user, user),
               {:ok, user} <- CRUD.get(User, id),
               do: User.changeset(user)
      end

    case changeset do
      :error -> {:error, :not_authorized}
      nil -> {:error, :not_found}
      _ -> render(conn, "form.html", user: user, changeset: changeset)
    end
  end

  def update(conn, %{"resource" => resource, "id" => id} = assigns) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    {module, params} =
      case resource do
        "categories" ->
          with :ok <- Bodyguard.permit(Category, :create_category, user),
               do: {Category, Map.get(assigns, "category")}

        "classrooms" ->
          with :ok <- Bodyguard.permit(Classroom, :create_classroom, user),
               do: {Category, Map.get(assigns, "classroom")}

        "rotation_groups" ->
          with :ok <- Bodyguard.permit(RotationGroup, :create_rotation_group, user),
               do: {RotationGroup, Map.get(assigns, "rotation_group")}

        "rotations" ->
          with :ok <- Bodyguard.permit(Rotation, :create_rotation, user),
               do: {Rotation, Map.get(assigns, "rotation")}

        "semesters" ->
          with :ok <- Bodyguard.permit(Semester, :create_semester, user),
               do: {Semester, Map.get(assigns, "semester")}

        "students" ->
          with :ok <- Bodyguard.permit(Student, :create_student, user),
               do: {Student, Map.get(assigns, "student")}

        "users" ->
          with :ok <- Bodyguard.permit(User, :create_user, user),
               do: {User, Map.get(assigns, "user")}
      end

    case params do
      nil ->
        {:error, :bad_request}

      %{} ->
        case CRUD.update(module, id, params) do
          {:ok, data} ->
            conn
            |> put_flash(
              :info,
              ~s(#{module |> to_string |> String.split(".") |> List.last()} #{
                Dashboardable.title_for(module, data)
              } updated!)
            )
            |> redirect(to: Routes.crud_path(conn, :index, module.__schema__(:source)))


          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "form.html", changeset: changeset, user: user)
        end
    end
  end

  def delete(conn, %{"resource" => resource, "id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    {module, data} =
      case resource do
        "categories" ->
          with :ok <- Bodyguard.permit(Category, :list_categories, user),
               do: {Category, CRUD.delete(Category, id)}

        "classrooms" ->
          with :ok <- Bodyguard.permit(Classroom, :list_classrooms, user),
               do: {Classroom, CRUD.delete(Classroom, id)}

        "rotation_groups" ->
          with :ok <- Bodyguard.permit(RotationGroup, :list_rotation_groups, user),
               do: {RotationGroup, CRUD.delete(RotationGroup, id)}

        "rotations" ->
          with :ok <- Bodyguard.permit(Rotation, :list_rotations, user),
               do: {Rotation, CRUD.delete(Rotation, id)}

        "semesters" ->
          with :ok <- Bodyguard.permit(Semester, :list_semesters, user),
               do: {Semester, CRUD.delete(Semester, id)}

        "students" ->
          with :ok <- Bodyguard.permit(Student, :list_student, user),
               do: {Student, CRUD.delete(Student, id)}

        "users" ->
          with :ok <- Bodyguard.permit(User, :list_users, user), do: {User, CRUD.delete(User, id)}
      end

    case data do
      {:ok, data} ->
        conn
        |> put_flash(
          :info,
          ~s(#{module |> to_string |> String.split(".") |> List.last()} #{
            Dashboardable.title_for(module, data)
          } deleted!)
        )
        |> redirect(to: Routes.crud_path(conn, :index, module.__schema__(:source)))

      _ ->
        conn
        |> put_flash(
          :error,
          ~s(#{module |> to_string |> String.split(".") |> List.last()} #{
            Dashboardable.title_for(module, data)
          } could not be deleted!)
        )
        |> redirect(to: Routes.crud_path(conn, :index, module.__schema__(:source)))
    end
  end
end
