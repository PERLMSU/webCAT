defmodule WebCATWeb.Macros.Router do
  def compile_router(env, resources) do
    router_ast =
      Enum.map(resources, fn %{schema: schema, options: options} ->
        controller_module =
          Module.concat([env.module, Controller, List.last(Module.split(schema))])

        collection_name =
          options
          |> Keyword.fetch!(:collection_name)
          |> String.downcase()
          |> String.split()
          |> Enum.join("_")

        quote do
          resources(unquote("/#{collection_name}"), unquote(controller_module),
            name: unquote(options[:item_name])
          )

          get(unquote("/#{collection_name}"), unquote(controller_module), :import,
            name: unquote(options[:item_name])
          )

          post(unquote("/#{collection_name}"), unquote(controller_module), :import_submit,
            name: unquote(options[:item_name])
          )
        end
      end)

    quote do
      use WebCATWeb, :router

      scope "/" do
        unquote(router_ast)
      end
    end
  end
end
