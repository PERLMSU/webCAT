defmodule WebCATWeb.JSONEncoder do
  @moduledoc """
  Custom encoder that uses Jason and snake_case for rendering json
  """

  use ProperCase.JSONEncoder, json_encoder: Jason, transform: &ProperCase.to_camel_case/1
end
