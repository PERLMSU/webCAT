defmodule WebCATWeb.ClassroomController do
  alias WebCATWeb.ClassroomView
  alias WebCAT.Rotations.Classroom

  use WebCATWeb.ResourceController,
    schema: Classroom,
    view: ClassroomView,
    type: "classroom",
    filter: ~w(course_code),
    sort: ~w(course_code name inserted_at updated_at)

end
