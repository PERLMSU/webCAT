defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_secure_browser_headers)
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
    resources("/users", UserController, except: ~w(new edit)a)

    # Classrooms
    resources("/classrooms", ClassroomController, except: ~w(new edit)a)
    resources("/semesters", SemesterController, except: ~w(new edit)a)
    resources("/sections", SectionController, except: ~w(new edit)a)
    post("/sections/:id/import", SectionController, :import)
    resources("/rotations", RotationController, except: ~w(new edit)a)
    resources("/rotation_groups", RotationGroupController, except: ~w(new edit)a)

    # Feedback
    resources("/categories", CategoryController, except: ~w(new edit)a)
    resources("/observations", ObservationController, except: ~w(new edit)a)
    resources("/feedback", FeedbackController, except: ~w(new edit)a)
    resources("/explanations", ExplanationController, except: ~w(new edit)a)
    resources("/drafts", DraftController, except: ~w(new edit)a)
    resources("/drafts/:draft_id/comments", CommentController, except: ~w(new edit)a)
    resources("/drafts/:draft_id/grades", GradeController, except: ~w(new edit)a)

    # Feedback writer
    get(
      "/rotation_groups/:rotation_group_id/feedback/:student_id",
      StudentFeedbackController,
      :index
    )

    post(
      "/rotation_groups/:rotation_group_id/feedback/:student_id/:feedback_id",
      StudentFeedbackController,
      :create
    )

    delete(
      "/rotation_groups/:rotation_group_id/feedback/:student_id/:feedback_id",
      StudentFeedbackController,
      :delete
    )

    # Feedback writer - explanations
    get(
      "/rotation_groups/:rotation_group_id/feedback/:student_id/:feedback_id/explanations",
      StudentExplanationController,
      :index
    )

    post(
      "/rotation_groups/:rotation_group_id/feedback/:student_id/:feedback_id/explanations/:explanation_id",
      StudentExplanationController,
      :create
    )

    delete(
      "/rotation_groups/:rotation_group_id/feedback/:student_id/:feedback_id/explanations/:explanation_id",
      StudentExplanationController,
      :delete
    )
  end

  scope "/", WebCATWeb do
    pipe_through(~w(browser)a)

    get("/", IndexController, :redirect_index)
    get("/app/*path", IndexController, :index)
  end
end
