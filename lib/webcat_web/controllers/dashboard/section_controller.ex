defmodule WebCATWeb.SectionController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Section, Sections, Semesters}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"semester_id" => semester_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         sections <- Sections.list(semester_id),
         {:ok, semester} <- Semesters.get(semester_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        sections: sections,
        semester: semester
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- Sections.get(id) do
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
         {:ok, semester} <- Semesters.get(semester_id) do
      conn
      |> render("new.html",
        user: user,
        changeset: Section.changeset(%Section{semester: semester, semester_id: semester_id}),
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
          |> redirect(to: Routes.section_path(conn, :show, section.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom"
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- Sections.get(id) do
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
         {:ok, section} <- Sections.get(id) do
      case CRUD.update(Section, section, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Section updated!")
          |> redirect(to: Routes.section_path(conn, :show, id))

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

    with :ok <- is_authorized?() do
      case CRUD.delete(Section, id) do
        {:ok, section} ->
          conn
          |> put_flash(:info, "Section deleted successfully")
          |> redirect(to: Routes.section_path(conn, :index, semester_id: section.semester_id))

        {:error, %Ecto.Changeset{}} ->
          conn
          |> put_flash(:error, "Section deletion failed")
          |> redirect(to: Routes.section_path(conn, :index))
      end
    end
  end
end
