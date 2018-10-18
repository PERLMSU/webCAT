defmodule WebCAT.Email do
  import Bamboo.Email
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
    |> html_body(~s(<a href="#{password_reset_url(WebCATWeb.Endpoint, :reset, token)}">))
    |> text_body("Token: #{token}")
  end

  @doc """
  Create an email to be sent for confirmation
  """
  @spec confirmation(String.t(), String.t()) :: Bamboo.Email.t()
  def confirmation(email, token) do
    new_email()
    |> to(email)
    |> from("no-reply@webcat.io")
    |> subject("Password Reset")
    |> html_body(~s(<a href="#{email_confirmation_url(WebCATWeb.Endpoint, :confirm, token)}">))
    |> text_body("Token: #{token}")
  end
end
