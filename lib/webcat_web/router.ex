defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug(:accepts, ~w(html))
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ~w(json))
    plug(:put_secure_browser_headers)
    # plug(JSONAPI.ContentTypeNegotiation)
    plug(JSONAPI.ResponseContentType)
    plug(JSONAPI.UnderscoreParameters)
  end

  pipeline :authenticated do
    plug(WebCATWeb.Auth.Pipeline)
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(Guardian.Plug.LoadResource)
  end

  scope "/api/auth", WebCATWeb do
    pipe_through(~w(api)a)

    post("/login", AuthController, :login)
    post("/password_reset", AuthController, :start_password_reset)
    post("/password_reset/finish", AuthController, :finish_password_reset)
  end

  scope "/api", WebCATWeb do
    pipe_through(~w(api authenticated)a)

    # Accounts
    resources("/user", ProfileController, singleton: true, only: ~w(show update)a)
    api_resource("/users", UserController)
    post("/users/:id/profile_picture", UserController, :profile_picture)

    # Classrooms
    api_resource("/classrooms", ClassroomController)
    api_resource("/semesters", SemesterController)
    api_resource("/sections", SectionController)
    post("/sections/:id/import", SectionController, :import)
    api_resource("/rotations", RotationController)
    api_resource("/rotation_groups", RotationGroupController)

    # Feedback
    api_resource("/categories", CategoryController)
    api_resource("/observations", ObservationController)
    api_resource("/feedback", FeedbackController)
    api_resource("/explanations", ExplanationController)
    api_resource("/drafts", DraftController)
    post("/drafts/:id/send_email", DraftController, :send_email)
    api_resource("/comments", CommentController)
    api_resource("/grades", GradeController)
    api_resource("/student_feedback", StudentFeedbackController)
    api_resource("/student_explanations", StudentExplanationController)
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser)a)

    get("/", IndexController, :redirect_index)
    get("/app/*path", IndexController, :index)
  end
end
