defmodule WebCATWeb.SemestersView do
  use WebCATWeb, :view

  @doc """
  Format a semester
  """
  def clean_semester(semester) do
    semester
    |> Map.from_struct()
    |> Map.update!(:start_date, fn value ->
      "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{Timex.format!(value, "{relative}", :relative)})"
    end)
    |> Map.update!(:end_date, fn value ->
      "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{Timex.format!(value, "{relative}", :relative)})"
    end)
  end
end
