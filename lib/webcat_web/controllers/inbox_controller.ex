defmodule WebCATWeb.InboxController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.Repo
  import Ecto.Query
  import Ecto.Changeset

  alias WebCAT.Feedback.{Draft, Comment, Grade, Observation, StudentFeedback, Category}
  alias WebCAT.Accounts.User
  alias WebCAT.CRUD
  alias WebCAT.Rotations.Classroom
  alias WebCAT.Feedback.Drafts

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, params) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      drafts_query =
        Draft
        |> join(:left, [d], c in assoc(d, :comments))
        |> join(:left, [d], rg in assoc(d, :rotation_group))
        |> join(:left, [d], u in assoc(d, :user))
        |> join(:left, [_d, _c, rg, _u], u in assoc(rg, :users))
        |> join(:left, [_d, _c, rg, _u, _users], r in assoc(rg, :rotation))
        |> join(:left, [_d, _c, _rg, _u, _users, r], sec in assoc(r, :section))
        |> join(:left, [_d, _c, _rg, _u, _users, _r, sec], sem in assoc(sec, :semester))
        |> join(:left, [_d, _c, _rg, _u, _users, _r, _sec, sem], class in assoc(sem, :classroom))
        |> order_by([d], d.updated_at)
        |> preload([_, c, rg, u, users, r, sec, sem, class],
          comments: c,
          user: u,
          rotation_group:
            {rg, users: users, rotation: {r, section: {sec, semester: {sem, classroom: class}}}}
        )

      drafts =
        if Terminator.has_role?(user.performer, :admin) do
          drafts_query
          |> Repo.all()
        else
          drafts_query
          |> where([_, _, _, _, u], ^user.id in u.id)
          |> Repo.all()
        end

      classrooms = from(c in Classroom) |> Repo.all()

      key_params =
        params
        |> Map.take(~w(classroom_id semester_id section_id))
        |> Enum.reduce([], fn {key, value}, params ->
          Keyword.put(params, String.to_atom(key), value)
        end)

      render(conn, "index.html",
        user: user,
        selected: "inbox",
        drafts: drafts,
        classrooms: classrooms,
        params: key_params
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      from(draft in Draft,
        where: draft.id == ^id,
        left_join: comments in assoc(draft, :comments),
        left_join: grades in assoc(draft, :grades),
        left_join: category in assoc(grades, :category),
        left_join: user in assoc(comments, :user),
        preload: [grades: {grades, category: category}, comments: {comments, user: user}]
      )
      |> Repo.one()
      |> case do
        %Draft{} = draft ->
          render(conn, "show.html",
            user: user,
            selected: "inbox",
            draft: draft,
            comment_changeset: Comment.changeset(%Comment{user_id: user.id})
          )

        nil ->
          {:error, :not_found}
      end
    end
  end

  def new(conn, user, %{"group_id" => group_id, "user_id" => user_id}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?(),
         {:ok, student} <- CRUD.get(User, user_id) do
      observations = StudentFeedback.by_observation(group_id, user_id)

      categories =
        from(c in Category,
          where: is_nil(c.parent_category_id),
          left_join: class in assoc(c, :classroom),
          left_join: sem in assoc(class, :semesters),
          left_join: sec in assoc(sem, :sections),
          left_join: rot in assoc(sec, :rotations),
          left_join: rg in assoc(rot, :rotation_groups),
          where: rg.id == ^group_id
        )
        |> Repo.all()

      changeset =
        Draft.changeset(%Draft{
          rotation_group_id: group_id,
          user_id: user_id,
          grades:
            Enum.map(categories, fn category ->
              Grade.changeset(%Grade{
                category_id: category.id,
                category: category
              })
            end)
        })

      render(conn, "new.html",
        user: user,
        selected: "inbox",
        student: student,
        observations: observations,
        categories: categories,
        changeset: changeset
      )
    end
  end

  def create(conn, user, %{"draft" => draft}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    IO.inspect(draft)

    with :ok <- is_authorized?() do
      case CRUD.create(Draft, draft) do
        {:ok, draft} ->
          conn
          |> put_flash(:info, "Draft created!")
          |> redirect(to: Routes.inbox_path(conn, :show, draft.id))

        {:error, changeset} ->
          IO.inspect(changeset)

          with {:ok, student} <- CRUD.get(User, changeset.data.user_id),
               observations =
                 StudentFeedback.by_observation(
                   changeset.data.rotation_group_id,
                   changeset.data.user_id
                 ) do
            render(conn, "new.html",
              user: user,
              selected: "inbox",
              student: student,
              observations: observations,
              changeset: changeset
            )
          end
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, draft} <- CRUD.get(Draft, id),
         :ok <- Bodyguard.permit(Draft, :update, user, draft) do
      students =
        Student
        |> join(:left, [s], rg in assoc(s, :rotation_groups))
        |> where([_, rg], rg.id == ^draft.rotation_group_id)
        |> Repo.all()

      observations =
        Observation
        |> where([o], o.rotation_group_id == ^draft.rotation_group_id)
        |> Repo.all()

      render(conn, "edit.html",
        user: user,
        selected: "feedback",
        students: students,
        observations: observations,
        changeset: Draft.changeset(draft)
      )
    end
  end

  def update(conn, %{"id" => id, "draft" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, draft} <- CRUD.get(Draft, id),
         :ok <- Bodyguard.permit(Draft, :update, user, draft) do
      case CRUD.update(Draft, draft, update) do
        {:ok, _} ->
          {:ok, observation} = CRUD.get(Observation, draft.observation_id)

          conn
          |> put_flash(:info, "Draft updated!")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )

        {:error, %Ecto.Changeset{} = changeset} ->
          students =
            Student
            |> join(:left, [s], rg in assoc(s, :rotation_groups))
            |> where([_, rg], rg.id == ^draft.rotation_group_id)
            |> Repo.all()

          observations =
            Observation
            |> where([o], o.rotation_group_id == ^draft.rotation_group_id)
            |> Repo.all()

          render(conn, "edit.html",
            user: user,
            selected: "feedback",
            students: students,
            observations: observations,
            changeset: changeset
          )
      end
    end
  end
end
