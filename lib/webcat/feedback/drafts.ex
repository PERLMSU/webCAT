defmodule WebCAT.Feedback.Drafts do
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Feedback.Draft
  alias WebCAT.Rotations.Rotation

  def draft_status_breakdown(nil), do: nil

  def draft_status_breakdown(%Rotation{id: id}) do
    query =
      from(d in Draft,
        left_join: rg in assoc(d, :rotation_group),
        where: rg.rotation_id == ^id
      )

    unreviewed = Repo.aggregate(from(d in query, where: d.status == "unreviewed"), :count, :id)
    reviewing = Repo.aggregate(from(d in query, where: d.status == "reviewing"), :count, :id)

    needs_revision =
      Repo.aggregate(from(d in query, where: d.status == "needs_revision"), :count, :id)

    approved = Repo.aggregate(from(d in query, where: d.status == "approved"), :count, :id)
    emailed = Repo.aggregate(from(d in query, where: d.status == "emailed"), :count, :id)

    [
      ["Unreviewed", unreviewed],
      ["Reviewing", reviewing],
      ["Needs Revision", needs_revision],
      ["Approved", approved],
      ["Emailed", emailed]
    ]
  end

  @doc """
  Something is definitely off here
  """
  def weekly_draft_progress(nil), do: nil

  def weekly_draft_progress(%Rotation{id: id}) do
    total_weekly_drafts =
      from(d in Draft,
        left_join: u in assoc(d, :user),
        left_join: rg in assoc(d, :rotation_group),
        where: rg.rotation_id == ^id,
        select: u
      )
      |> Repo.aggregate(:count, :id)

    if total_weekly_drafts != 0 do
      query =
        from(d in Draft,
          left_join: rg in assoc(d, :rotation_group),
          where: rg.rotation_id == ^id
        )

      written =
        Repo.aggregate(
          from(d in query, where: d.status in ["unreviewed", "reviewing", "needs_revision"]),
          :count,
          :id
        )

      approved =
        Repo.aggregate(from(d in query, where: d.status in ["approved", "emailed"]), :count, :id)

      %{written: written / total_weekly_drafts, approved: approved / total_weekly_drafts}
    else
      %{written: 0, approved: 0}
    end
  end
end
