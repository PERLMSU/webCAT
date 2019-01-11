defmodule WebCATWeb.RouterHelpers do
  defmacro importable_resources(path, controller_module) do
    quote do
      resources(unquote(path), unquote(controller_module))
      get(unquote("#{path}/import"), unquote(controller_module), :import)
      post(unquote("#{path}/import"), unquote(controller_module), :import)
    end
  end
end
