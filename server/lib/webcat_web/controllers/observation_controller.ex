defmodule WebCATWeb.ObservationController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Feedback.{Observation, Observations}
  alias WebCATWeb.{ObservationView, ExplanationView, NoteView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :list_observations, user),
         observations <- CRUD.list(Observation, limit: limit, offset: offset) do
      conn
      |> render(ObservationView, "list.json", observations: observations)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, observation} <- CRUD.get(Observation, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :show_observation, user, observation) do
      conn
      |> render(ObservationView, "show.json", observation: observation)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :create_observation, user),
         {:ok, observation} <- CRUD.create(Observation, params) do
      conn
      |> put_status(:created)
      |> render(ObservationView, "show.json", observation: observation)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_observation} <- CRUD.get(Observation, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :update_observation, user, subject_observation),
         {:ok, updated} <- CRUD.update(Observation, subject_observation.id, params) do
      conn
      |> render(ObservationView, "show.json", observation: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_observation} <- CRUD.get(Observation, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :delete_observation, user, subject_observation),
         {:ok, _} <- CRUD.delete(Observation, subject_observation.id) do
      send_resp(conn, :ok, "")
    end
  end

  def explanations(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_observation} <- CRUD.get(Observation, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Feedback,
             :list_observation_explanations,
             user,
             subject_observation
           ),
         explanations <-
           Observations.explanations(subject_observation.id, limit: limit, offset: offset) do
      conn
      |> render(ExplanationView, "list.json", explanations: explanations)
    end
  end

  def notes(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_observation} <- CRUD.get(Observation, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Feedback,
             :list_observation_notes,
             user,
             subject_observation
           ),
         notes <- Observations.notes(subject_observation.id, limit: limit, offset: offset) do
      conn
      |> render(NoteView, "list.json", notes: notes)
    end
  end
end
