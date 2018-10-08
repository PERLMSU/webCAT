defmodule WebCATWeb.RotationsView do
  use WebCATWeb, :view

  @doc """
  Format a rotation
  """
  def clean_rotation(rotation) do
    rotation
    |> Map.from_struct()
    |> Map.update!(:start_date, fn value ->
      "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
        Timex.format!(value, "{relative}", :relative)
      })"
    end)
    |> Map.update!(:end_date, fn value ->
      "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
        Timex.format!(value, "{relative}", :relative)
      })"
    end)
  end
end
