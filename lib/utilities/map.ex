defmodule Gateway.Utilities.Map do 

  @doc "Allows for replacement of entire key/value pair in map
  according to transformation function"
  def transform_keyvalue(map, fun) when is_map(map) do
    for {k, v} <- map, into: %{} do 
      fun.(k, v)
    end
  end

end
