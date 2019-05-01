defmodule WebCATWeb.Email do
  use Bamboo.Phoenix, view: WebCATWeb.EmailView
  alias WebCATWeb.Router.Helpers, as: Routes
  alias WebCAT.Feedback.Draft

  @doc """
  Create an email to be sent in the case of a password beimg reset
  """
  @spec password_reset(String.t(), String.t()) :: Bamboo.Email.t()
  def password_reset(email, token) do
    new_email()
    |> to(email)
    |> from("no-reply@webcat.io")
    |> subject("Password Reset")
    |> render("reset.html",
      link: Routes.index_url(WebCATWeb.Endpoint, :index, ["app"], reset_token: token)
    )
  end

  @doc """
  Create an email to be sent for confirmation
  """
  @spec confirmation(String.t(), String.t()) :: Bamboo.Email.t()
  def confirmation(email, token) do
    new_email()
    |> to(email)
    |> from("no-reply@webcat.io")
    |> subject("Confirm Email")
    |> render("confirmation.html",
      link: Routes.index_url(WebCATWeb.Endpoint, :index, ["app"], confirmation_token: token)
    )
  end

  def draft(%Draft{} = draft) do
    date = Timex.format!(Timex.now(), "{M}/{D}/{YYYY}")

    new_email()
    |> to(draft.user.email)
    |> from("no-reply@webcat.io")
    |> subject("Weekly Feedback - #{date}")
    |> render("draft.html", draft: draft, date: date)
  end
end
