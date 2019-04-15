defmodule WebCATWeb.CategoryView do
  use WebCATWeb, :dashboard_view

  alias WebCAT.Rotations.{Classroom, Classrooms}
  import Ecto.Changeset
end
