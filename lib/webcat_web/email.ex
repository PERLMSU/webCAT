defmodule WebCATWeb.Email do
  use Bamboo.Phoenix, view: WebCATWeb.EmailView
  import WebCATWeb.Router.Helpers

  @doc """
  Create an email to be sent in the case of a password beimg reset
  """
  @spec password_reset(String.t(), String.t()) :: Bamboo.Email.t()
  def password_reset(email, token) do
    new_email()
    |> to(email)
    |> from("no-reply@webcat.io")
    |> subject("Password Reset")
    |> render("reset.html", link: password_reset_url(WebCATWeb.Endpoint, :reset, token))
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
      link: login_url(WebCATWeb.Endpoint, :credential_login, token: token)
    )
  end
end
