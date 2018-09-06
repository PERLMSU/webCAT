defmodule WebCATWeb.Router do
  use WebCATWeb, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug(:accepts, ["json"])
    plug(ProperCase.Plug.SnakeCaseParams)
  end

  scope "/", WebCATWeb do
    pipe_through(:api)

    post("/auth/login", AuthController, :login)

    resources("/users", UserController, only: ~w(index show update)a)
    get("/users/:id/notifications", UserController, :notifications)
    get("/users/:id/classrooms", UserController, :classrooms)
    get("/users/:id/rotation_groups", UserController, :rotation_groups)

    get("/users/confirmations/:token", ConfirmationController, :show)
    patch("/users/confirmations/:token", ConfirmationController, :update)

    get("/users/resets/:token", ResetController, :show)
    patch("/users/resets/:token", ResetController, :update)
  end

  scope "/", WebCATWeb do
    pipe_through(:api)

    resources("/categories", CategoryController, only: ~w(index show create update delete)a)
    get("/categories/:id/observations", CategoryController, :observations)

    resources("/drafts", DraftController, only: ~w(index show create update delete)a)
    resources("/emails", EmailController, only: ~w(show create)a)
    resources("/explanations", ExplanationController, only: ~w(index show create update delete)a)

    resources("/feedback", FeedbackController, only: ~w(index show create update delete)a)
    get("/feedback/:id/explanations", FeedbackController, :explanations)

    resources("/grades", GradeController, only: ~w(index show create update delete)a)
    resources("/notes", NoteController, only: ~w(index show create update delete)a)

    resources("/observations", ObservationController, only: ~w(index show create update delete)a)
    get("/observations/:id/feedback", ObservationController, :feedback)
    get("/observations/:id/notes", ObservationController, :notes)
  end

  scope "/", WebCATWeb do
    pipe_through(:api)

    resources("/classrooms", ClassroomController, only: ~w(index show create update delete)a)
    get("/classrooms/:id/instructors", ClassroomController, :instructors)
    get("/classrooms/:id/rotations", ClassroomController, :rotations)
    get("/classrooms/:id/students", ClassroomController, :students)

    resources("/rotation_groups", RotationGroupController, only: ~w(index show create update delete)a)
    get("/rotation_groups/:id/drafts", RotationGroupController, :drafts)
    get("/rotation_groups/:id/students", RotationGroupController, :students)

    resources("/rotations", RotationController, only: ~w(index show create update delete)a)
    get("/rotations/:id/rotation_groups", RotationController, :rotation_groups)

    resources("/semesters", SemesterController, only: ~w(index show create update delete)a)
    get("/semesters/:id/classrooms", SemesterController, :classrooms)

    resources("/students", StudentController, only: ~w(index show create update delete)a)
    get("/students/:id/drafts", StudentController, :drafts)
    get("/students/:id/notes", StudentController, :notes)
    get("/students/:id/rotation_groups", StudentController, :rotation_groups)
  end
end
