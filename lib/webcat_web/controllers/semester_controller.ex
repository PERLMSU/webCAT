defmodule WebCATWeb.SemesterController do
  use WebCATWeb.Macros.Controller,
    schema: WebCAT.Rotations.Semester,
    item_name: "Semester",
    collection_name: "Semesters"
end
