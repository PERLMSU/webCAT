defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :not_authenticated do
    plug(WebCATWeb.Auth.Pipeline)
    plug(Guardian.Plug.EnsureNotAuthenticated)
  end

  pipeline :authenticated do
    plug(WebCATWeb.Auth.Pipeline)
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(Guardian.Plug.LoadResource)
  end

  scope "/auth", WebCATWeb do
    pipe_through(~w(api)a)

    post("/login", AuthController, :login)
    post("/password_reset", AuthController, :start_password_reset)
    post("/password_reset/finish", AuthController, :finish_password_reset)
  end

  scope "/api", WebCATWeb do
    pipe_through(~w(api authenticated)a)

    # Accounts
    resources("/users", UserController)

    # Classrooms
    resources("/classrooms", ClassroomController)
    resources("/semesters", SemesterController)
    resources("/sections", SectionController)
    resources("/rotations", RotationsController)
    resources("/rotation_groups", RotationGroupsController)

    # Feedback
    resources("/categories", CategoryController)
    resources("/observations", ObservationController)
    resources("/feedback", FeedbackController)
    resources("/drafts", DraftController)
    resources("/drafts/:draft_id/comments", CommentController)
    resources("/drafts/:draft_id/grades", GradeController)
  end

  scope "/app", WebCATWeb do
    pipe_through(~w(browser)a)

    get("/*path", IndexController, :index)
  end
end
