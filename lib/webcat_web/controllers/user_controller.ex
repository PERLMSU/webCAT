defmodule WebCATWeb.UserController do
  alias WebCATWeb.UserView
  alias WebCAT.Accounts.User

  use WebCATWeb.ResourceController,
    schema: User,
    view: UserView,
    type: "user",
    filter: ~w(active role),
    sort: ~w(email first_name last_name middle_name nickname active role inserted_at updated_at)

  def profile_picture(conn, user, params) do
    with {:params, %{"id" => user_id, "picture" => %Plug.Upload{path: path}}} <-
           {:params, params},
         {:auth, true} <- {:auth, user_id == user.id or user.role in ~w(admin)},
         {:copy, :ok} <-
           {:copy, File.cp(path, Application.app_dir(:webcat, "priv/media/profiles/#{user_id}"))} do
      send_resp(conn, :no_content, "")
    else
      {:params, _} ->
        {:error, :bad_request, dgettext("errors", "Profile picture upload incorrect format")}

      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to upload profile picture")}

      {:copy, _} ->
        {:error, :server_error, dgettext("errors", "Problem copying uploaded picture")}
    end
  end
end
