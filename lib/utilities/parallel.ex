defmodule Gateway.Utilities.Parallel do
  
  @doc "Parallel Map implementation stolen from Dave Thomas' book: 
  https://pragprog.com/book/elixir/programming-elixir. I altered it
  to protect it from the failure of the spawned processes. Also it returns
  an empty tuple on failure. Finally I added a timeout parameter so it can be 
  called with varying levels of tolerance."
  def map(collection, function, timeout) do
    me = self
    collection
      |> Enum.map(fn(elem) -> 
          spawn fn -> (
            send me, {self, function.(elem)}) 
          end 
        end)
      |> Enum.map(fn(pid) ->
          receive do {^pid, result} ->
            result
          after timeout ->
            {:error, :processfailed}      
          end
        end)

  end
    
end
