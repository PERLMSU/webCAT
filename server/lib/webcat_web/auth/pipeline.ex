defmodule WebCATWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :webcat,
    error_handler: WebCATWeb.Auth.ErrorHandler,
    module: WebCATWeb.Auth.Guardian

    plug(Guardian.Plug.VerifyHeader)
    plug(Guardian.Plug.LoadResource)
    plug(Guardian.Plug.EnsureAuthenticated)
end
