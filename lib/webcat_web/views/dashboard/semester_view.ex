defmodule WebCATWeb.SemesterView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.{Section, Classroom, Classrooms}
  alias WebCAT.CRUD

  import Ecto.Changeset
end
