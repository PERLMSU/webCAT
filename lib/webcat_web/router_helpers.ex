defmodule WebCATWeb.RouterHelpers do
  defmacro importable_resources(path, controller_module) do
    quote do
      get(unquote("#{path}/import"), unquote(controller_module), :import)
      post(unquote("#{path}/import"), unquote(controller_module), :handle_import)

      get(unquote("#{path}/:id/delete"), unquote(controller_module), :delete)
      resources(unquote(path), unquote(controller_module), except: ~w(delete)a)
    end
  end
end
