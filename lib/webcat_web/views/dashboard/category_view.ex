defmodule WebCATWeb.CategoryView do
  use WebCATWeb, :view

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, Classrooms}
  alias WebCAT.Feedback.Categories
  import Ecto.Changeset
end
