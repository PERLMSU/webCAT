defmodule WebCATWeb.SectionController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Semester, Section}

  @list_preload [:users, rotations: [:rotation_groups]]
  @preload [semester: [:classroom]] ++ @list_preload

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"semester_id" => semester_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, semester} <- CRUD.get(Semester, semester_id, preload: ~w(classroom)a),
         sections <-
           CRUD.list(Section, preload: @list_preload, where: [semester_id: semester_id]) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        semester: semester,
        sections: sections
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- CRUD.get(Section, id, preload: @preload) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        section: section
      )
    end
  end

  def new(conn, user, %{"semester_id" => semester_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, semester} <- CRUD.get(Semester, semester_id, preload: ~w(classroom)a) do
      conn
      |> render("new.html",
        user: user,
        changeset: Section.changeset(%Section{}, %{}),
        semester: semester,
        selected: "classroom"
      )
    end
  end

  def create(conn, user, %{"section" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Section, params) do
        {:ok, section} ->
          conn
          |> put_flash(:info, "Section created!")
          |> redirect(to: Routes.section_path(conn, :show, section.semester_id, section.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          with {:ok, semester} <- CRUD.get(Semester, Map.get(params, "semester_id"), preload: ~w(classroom)a) do
            conn
            |> render("new.html",
              user: user,
              changeset: changeset,
              selected: "classroom",
              semester: semester
            )
          end
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- CRUD.get(Section, id, preload: @preload) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Section.changeset(section)
      )
    end
  end

  def update(conn, user, %{"id" => id, "section" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- CRUD.get(Section, id, preload: @preload) do
      case CRUD.update(Section, section, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Section updated!")
          |> redirect(to: Routes.section_path(conn, :show, section.semester_id, id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "classroom",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- CRUD.get(Section, id) do
      case CRUD.delete(Section, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Section deleted successfully")
          |> redirect(to: Routes.section_path(conn, :index, section.semester_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "Section deletion failed")
          |> redirect(to: Routes.section_path(conn, :index, section.semester_id))
      end
    end
  end
end
