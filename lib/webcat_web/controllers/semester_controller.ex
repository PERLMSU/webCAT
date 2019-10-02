defmodule WebCATWeb.SemesterController do
  alias WebCATWeb.SemesterView
  alias WebCAT.Rotations.Semester

  use WebCATWeb.ResourceController,
    schema: Semester,
    view: SemesterView,
    type: "semester",
    filter: ~w(name),
    sort: ~w(name start_date end_date inserted_at updated_at)
end
