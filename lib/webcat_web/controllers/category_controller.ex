defmodule WebCATWeb.CategoryController do
  alias WebCATWeb.CategoryView
  alias WebCAT.Feedback.Category

  use WebCATWeb.ResourceController,
    schema: Category,
    view: CategoryView,
    type: "category",
    filter: ~w(parent_category_id classroom_id),
    sort: ~w(name description parent_category_id classroom_id inserted_at updated_at)
end
