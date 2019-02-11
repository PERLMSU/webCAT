defmodule WebCATWeb.SectionController do
  use WebCATWeb, :controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Semester, Section}

  @list_preload [rotations: [:rotation_groups], students: ~w(user)a]
  @preload [semester: [:classroom]] ++ @list_preload

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, %{"semester_id" => semester_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Section, :list, user),
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

  def show(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, section} <- CRUD.get(Section, id, preload: @preload),
         :ok <- Bodyguard.permit(Section, :show, user, section) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        section: section
      )
    end
  end

  def new(conn, %{"semester_id" => semester_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Section, :create, user),
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

  def create(conn, %{"section" => params}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Section, :create, user) do
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

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, section} <- CRUD.get(Section, id, preload: @preload),
         :ok <- Bodyguard.permit(Section, :update, user, section) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Section.changeset(section)
      )
    end
  end

  def update(conn, %{"id" => id, "section" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, section} <- CRUD.get(Section, id, preload: @preload),
         :ok <- Bodyguard.permit(Section, :update, user, section) do
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

  def delete(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, section} <- CRUD.get(Section, id),
         :ok <- Bodyguard.permit(Section, :delete, user, section) do
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
