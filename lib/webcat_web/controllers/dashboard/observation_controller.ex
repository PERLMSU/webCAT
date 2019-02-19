defmodule WebCATWeb.ObservationController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Feedback.{Category, Observation}

  @list_preload ~w(feedback category)a
  @preload [:feedback, category: ~w(classroom)a]
  @category_preload ~w(classroom)a

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"category_id" => category_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, category} <- CRUD.get(Category, category_id, preload: @category_preload),
         observations <- CRUD.list(Observation, preload: @list_preload, where: [category_id: category_id]) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        category: category,
        observations: observations
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, observation} <- CRUD.get(Observation, id, preload: @preload) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        observation: observation
      )
    end
  end

  def new(conn, user, %{"category_id" => category_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, category} <- CRUD.get(Category, category_id, preload: @category_preload) do
      conn
      |> render("new.html",
        user: user,
        changeset: Observation.changeset(%Observation{}, %{}),
        category: category,
        selected: "classroom"
      )
    end
  end

  def create(conn, user, %{"observation" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Observation, params) do
        {:ok, observation} ->
          conn
          |> put_flash(:info, "Observation created!")
          |> redirect(to: Routes.observation_path(conn, :show, observation.category_id, observation.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          {:ok, category} = CRUD.get(Category, params["category_id"], preload: @category_preload)

          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom",
            category: category
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, observation} <- CRUD.get(Observation, id, preload: @preload) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Observation.changeset(observation)
      )
    end
  end

  def update(conn, user, %{"id" => id, "observation" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, observation} <- CRUD.get(Observation, id, preload: @preload) do
      case CRUD.update(Observation, observation, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Observation updated!")
          |> redirect(to: Routes.observation_path(conn, :show, observation.category_id, id))

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
         {:ok, observation} <- CRUD.get(Observation, id) do
      case CRUD.delete(Observation, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Observation deleted successfully")
          |> redirect(to: Routes.observation_path(conn, :index, observation.category_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "Observation deletion failed")
          |> redirect(to: Routes.observation_path(conn, :index, observation.category_id))
      end
    end
  end
end
