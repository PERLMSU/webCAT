defmodule WebCATWeb.RotationGroupController do
  alias WebCATWeb.{RotationGroupView, UserView, CategoryView}
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.CRUD

  use WebCATWeb.ResourceController,
    schema: RotationGroup,
    view: RotationGroupView,
    type: "rotation_group",
    filter: ~w(number section_id),
    sort: ~w(number section_id start_date end_date inserted_at updated_at)


  def students(conn, _user, %{"id" => id}) do
    with students <- RotationGroup.students(id) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("list.json", users: students)
    end
  end

  def classroom(conn, _user, %{"id" => id}) do
    with {:ok, classroom} <- RotationGroup.classroom(id) do
      conn
      |> put_status(200)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: classroom)
    else
      _ -> {:error, :not_found}
    end
  end

  def classroom_categories(conn, _user, %{"id" => id}) do
    with categories <- RotationGroup.categories(id) do
      conn
      |> put_status(200)
      |> put_view(CategoryView)
      |> render("list.json", categories: categories)
    else
      _ -> {:error, :not_found}
    end
  end
end
