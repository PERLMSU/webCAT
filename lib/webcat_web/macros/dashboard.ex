defmodule WebCATWeb.Macros.Dashboard do
  alias WebCATWeb.Macros.{View, Controller, Router}

  defmodule Resource do
    defstruct schema: nil,
              table_fields: nil,
              display_fields: nil,
              options: nil,
              association_data: nil
  end

  @doc """
  Do necessary setup for
  """
  defmacro __using__(_) do
    quote do
      import WebCATWeb.Macros.Dashboard

      Module.register_attribute(__MODULE__, :resources, accumulate: true)

      @before_compile WebCATWeb.Macros.Dashboard
    end
  end

  defmacro resource(module, do: block) do
    module = expand_alias(module, __CALLER__)

    quote do
      @resource unquote(module)
      unquote(block)

      @resources %Resource{
        schema: unquote(module),
        table_fields: @table_fields,
        display_fields: @display_fields,
        options: @options
      }
    end
  end

  defmacro title(binding, do: block) do
    quote do
      def title_for(@resource, unquote(binding)) do
        unquote(block)
      end
    end
  end

  defmacro display_fields(fields) do
    quote do
      @display_fields unquote(fields)
    end
  end

  defmacro table_fields(fields) do
    quote do
      @table_fields unquote(fields)
    end
  end

  @doc """
  Allows you to supply a function that tells how to display the data
  """
  defmacro display(binding, do: block) do
    quote do
      def display_resource(@resource, unquote(binding)) do
        unquote(block)
      end
    end
  end

  defmacro options(options) do
    quote do
      @options unquote(options)
    end
  end

  @doc """
  Allows how the data for a specific association is queried to be controlled.
  """
  defmacro association_data(key, parent_binding, do: block) do
    quote do
      def association_data(@resource, unquote(key), unquote(parent_binding)) do
        unquote(block)
      end
    end
  end

  @doc """
  Invoked before compilation of the target module
  """
  defmacro __before_compile__(env) do
    resources = Module.get_attribute(env.module, :resources)

    router_ast = Router.compile_router(env, resources)
    controller_ast = Controller.compile_controller(env, resources)
    view_ast = View.compile_view(env, resources)

    quote do
      defmodule Router do
        unquote(router_ast)
      end

      defmodule Controller do
        unquote(controller_ast)
      end

      defmodule View do
        def generate_form(schema, changeset, opts \\ [])
        def table_body(schema, data, options \\ [])

        unquote(view_ast)
      end

      # Fallthrough for querying association data
      def association_data(_module, _key, _parent), do: nil
    end
  end

  def get_route_name(env, module) do
    env.module
    |> Module.get_attribute(:resources)
    |> Enum.find(fn %{schema: schema} ->
      schema == module
    end)
    |> Map.fetch!(:options)
    |> Keyword.fetch!(:item_name)
  end

  def get_collection_name(env, module) do
    env.module
    |> Module.get_attribute(:resources)
    |> Enum.find(fn %{schema: schema} ->
      schema == module
    end)
    |> Map.fetch!(:options)
    |> Keyword.fetch!(:collection_name)
  end

  # Ripped directly from Ecto source because yeah
  defp expand_alias({:__aliases__, _, _} = ast, env),
    do: Macro.expand(ast, %{env | function: {:__schema__, 2}})

  defp expand_alias(ast, _env),
    do: ast
end
