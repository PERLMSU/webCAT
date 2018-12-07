defmodule WebCATWeb.CategoryController do
  use WebCATWeb.Macros.Controller,
    schema: WebCAT.Feedback.Category,
    item_name: "Category",
    collection_name: "Categories"
end
