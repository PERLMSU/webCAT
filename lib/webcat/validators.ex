defmodule WebCAT.Validators do
  @moduledoc """
  Custom ecto validators
  """

  import Ecto.Changeset

  @doc """
  Changeset validator that ensures that `to` occurs after `from`
  """
  def validate_dates_after(changeset, from, to, opts \\ []) do
    {_, from_value} = fetch_field(changeset, from)
    {_, to_value} = fetch_field(changeset, to)

    if from_value == nil or to_value == nil do
      changeset
    else
      if Timex.before?(from_value, to_value) do
        changeset
      else
        message = msg(opts, " must be before #{to}")
        add_error(changeset, from, message, to_field: to)
      end
    end
  end

  defp msg(opts, field \\ :message, message) do
    Keyword.get(opts, field, message)
  end
end
