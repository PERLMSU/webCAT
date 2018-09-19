defmodule WebCAT.Email do
  import Bamboo.Email

  @doc """
  Create an email to be sent in the case of a password beimg reset
  """
  @spec password_reset(String.t(), String.t()) :: Bamboo.Email.t()
  def password_reset(email, token) do
    new_email()
    |> to(email)
    |> from("no-reply@webcat.io")
    |> subject("Password Reset")
    |> html_body(~s(<a href="http://localhost:4000/profile/reset?token=#{token}">))
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
    |> html_body(~s(<a href="http://localhost:4000/confirm?token=#{token}">))
    |> text_body("Token: #{token}")
  end
end
