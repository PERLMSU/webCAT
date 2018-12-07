defmodule WebCATWeb.ClassroomView do
  use WebCATWeb.Macros.Dashboard,
    schema: WebCAT.Rotations.Classroom,
    item_name: "Classroom",
    collection_name: "Classrooms"
end
