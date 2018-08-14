defmodule WebCATWeb.ChangesetView do
  @moduledoc """
  Handle rendering changesets returned from errors
  """

  use WebCATWeb, :view

  alias Ecto.Changeset

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    if count = opts[:count] do
      Gettext.dngettext(WebCATWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(WebCATWeb.Gettext, "errors", msg, opts)
    end
  end

  def translate_errors(%Changeset{} = changeset) do
    Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: %Changeset{} = changeset}) do
    %{errors: translate_errors(changeset)}
  end
end
