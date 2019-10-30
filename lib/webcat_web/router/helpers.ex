defmodule WebCATWeb.Router.ExtraHelpers do
  defmacro api_resource(path, controller, opts \\ []) do
    quote do
      resources(
        unquote(path),
        unquote(controller),
        unquote(Keyword.put(opts, :except, ~w(new edit)a))
      )
    end
  end
end
