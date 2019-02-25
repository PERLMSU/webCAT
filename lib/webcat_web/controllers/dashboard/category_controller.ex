defmodule WebCATWeb.CategoryController do
  use WebCATWeb, :authenticated_controller
  use Anaphora
  alias WebCAT.CRUD
  alias WebCAT.Rotations.Classroom
  alias WebCAT.Feedback.{Category, Categories}

  action_fallback(WebCATWeb.FallbackController)

  @list_preload ~w(sub_categories)a
  @preload ~w(classroom parent_category)a ++ @list_preload

  def index(conn, user, %{"classroom_id" => classroom_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- CRUD.get(Classroom, classroom_id),
         categories <- Categories.list(classroom_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        classroom: classroom,
        categories: categories
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
    {:ok, category} <- Categories.get(id) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        category: category
      )
    end
  end

  def new(conn, user, %{"classroom_id" => classroom_id} = params) do
    permissions do
      has_role(:admin)
    end

    parent_category_id =
      aif(Map.get(params, "parent_category_id"),
        do: Integer.parse(it) |> Tuple.to_list() |> Enum.at(0)
      )

    with :ok <- is_authorized?(),
         {:ok, classroom} <- CRUD.get(Classroom, classroom_id) do
      conn
      |> render("new.html",
        user: user,
        changeset:
          Category.changeset(%Category{
            classroom_id: classroom_id,
            parent_category_id: parent_category_id
          }),
        classroom: classroom,
        selected: "classroom"
      )
    end
  end

  def create(conn, user, %{"category" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Category, params) do
        {:ok, category} ->
          conn
          |> put_flash(:info, "Category created!")
          |> redirect(to: Routes.category_path(conn, :show, category.classroom_id, category.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          {:ok, classroom} = CRUD.get(Classroom, params["classroom_id"])

          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom",
            classroom: classroom
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
    {:ok, category} <- CRUD.get(Category, id, preload: @preload) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Category.changeset(category)
      )
    end
  end

  def update(conn, user, %{"id" => id, "category" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
    {:ok, category} <- CRUD.get(Category, id, preload: @preload) do
      case CRUD.update(Category, category, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Category updated!")
          |> redirect(to: Routes.category_path(conn, :show, category.classroom_id, id))

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
    {:ok, category} <- CRUD.get(Category, id) do
      case CRUD.delete(Category, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Category deleted successfully")
          |> redirect(to: Routes.category_path(conn, :index, category.classroom_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "Category deletion failed")
          |> redirect(to: Routes.category_path(conn, :index, category.classroom_id))
      end
    end
  end
end
