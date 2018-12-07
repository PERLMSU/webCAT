defmodule WebCATWeb.SemesterView do
  use WebCATWeb.Macros.Dashboard,
    schema: WebCAT.Rotations.Semester,
    item_name: "Semester",
    collection_name: "Semesters"
end
