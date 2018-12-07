defmodule WebCATWeb.StudentView do
  use WebCATWeb.Macros.Dashboard,
    schema: WebCAT.Rotations.Student,
    item_name: "Student",
    collection_name: "Students"
end
