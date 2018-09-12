defmodule WebCATWeb.EmailView do
  @moduledoc """
  Render emails
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Email

  def render("list.json", %{emails: emails}) do
    render_many(emails, __MODULE__, "email.json")
  end

  def render("show.json", %{email: email}) do
    render_one(email, __MODULE__, "email.json")
  end

  def render("email.json", %{email: %Email{} = email}) do
    email
    |> Map.from_struct()
    |> Map.take(~w(id status status_message draft_id inserted_at updated_at)a)
  end
end
