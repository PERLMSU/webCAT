defmodule WebCATWeb.StudentController do
  use WebCATWeb.Macros.Controller,
    schema: WebCAT.Rotations.Student,
    item_name: "Student",
    collection_name: "Students"
end
