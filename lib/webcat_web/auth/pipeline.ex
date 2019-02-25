defmodule WebCATWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :webcat,
    error_handler: WebCATWeb.Auth.ErrorHandler,
    module: WebCATWeb.Auth.Guardian

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.VerifyHeader)
end
