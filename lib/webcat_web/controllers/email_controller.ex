defmodule WebCATWeb.EmailController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Feedback.Email
  alias WebCATWeb.EmailView

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, email} <- CRUD.get(Email, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :show_email, user, email) do
      conn
      |> render(EmailView, "show.json", email: email)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :create_email, user),
         {:ok, email} <- CRUD.create(Email, params) do
      conn
      |> put_status(:created)
      |> render(EmailView, "show.json", email: email)
    end
  end
end
