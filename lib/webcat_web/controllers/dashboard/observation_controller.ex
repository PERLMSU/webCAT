defmodule WebCATWeb.ObservationController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Feedback.{Observation, Observations, Categories}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"category_id" => category_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         observations <- Observations.list(category_id),
         {:ok, category} <- Categories.get(category_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        observations: observations,
        category: category
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, observation} <- Observations.get(id) do
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
         {:ok, category} <- Categories.get(category_id) do
      conn
      |> render("new.html",
        user: user,
        changeset: Observation.changeset(%Observation{category_id: category_id}),
        selected: "classroom",
        category: category
      )
    end
  end

  def create(conn, user, %{"observation" => params, "category_id" => category_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Observation, params) do
        {:ok, observation} ->
          conn
          |> put_flash(:info, "Observation created!")
          |> redirect(to: Routes.observation_path(conn, :show, observation.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          IO.inspect(changeset)

          with {:ok, category} <- Categories.get(category_id) do
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
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, observation} <- Observations.get(id) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Observation.changeset(observation),
        category: observation.category
      )
    end
  end

  def update(conn, user, %{"id" => id, "observation" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, observation} <- Observations.get(id) do
      case CRUD.update(Observation, observation, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Observation updated!")
          |> redirect(to: Routes.observation_path(conn, :show, id))

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
      case CRUD.delete(Observation, id) do
        {:ok, observation} ->
          conn
          |> put_flash(:info, "Observation deleted successfully")
          |> redirect(
            to: Routes.observation_path(conn, :index, category_id: observation.category_id)
          )

        {:error, %Ecto.Changeset{}} ->
          conn
          |> put_flash(:error, "Observation deletion failed")
          |> redirect(to: Routes.observation_path(conn, :index))
      end
    end
  end
end
