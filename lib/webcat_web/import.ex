defmodule WebCATWeb.Import do
  alias WebCAT.Repo
  alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup}
  alias WebCAT.Feedback.{Category, Observation, Feedback}
  alias WebCAT.Accounts.User
  alias Terminator.{Performer, Role}

  defmodule Status do
    defstruct state: :finished, time: nil, errors: []
  end

  defmodule Error do
    defstruct type: :format, for: nil, errors: []
  end

  def from_path(_path) do
    %Status{}
  end
end
