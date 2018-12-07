defmodule WebCATWeb.CategoryView do
  use WebCATWeb.Macros.Dashboard,
    schema: WebCAT.Feedback.Category,
    item_name: "Category",
    collection_name: "Categories"
end
