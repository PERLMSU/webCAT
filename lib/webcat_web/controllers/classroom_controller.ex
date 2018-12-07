defmodule WebCATWeb.ClassroomController do
  use WebCATWeb.Macros.Controller,
    schema: WebCAT.Rotations.Classroom,
    item_name: "Classroom",
    collection_name: "Classrooms"
end
