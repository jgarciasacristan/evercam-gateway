defmodule Gateway.Utilities.Parallel do
  
  @doc "Parallel Map implementation stolen from Dave Thomas' book: 
  https://pragprog.com/book/elixir/programming-elixir. I altered it
  to protect it from the failure of the spawned processes. Also it returns
  an indicative tuple on failure. Finally I added a timeout parameter so it can be 
  called with varying levels of tolerance."
  def map(collection, timeout \\ 1000, function) do
    me = self
    collection
      |> Enum.map(fn(elem) ->
          
          result_pid = spawn fn -> (
            receive do {pid, result} -> 
              send me, {self, result}
            after timeout ->
              send me, {self, {:error, :processfailed}}
            end)
          end

          spawn fn -> (
            send result_pid, {self, function.(elem)}) 
          end

          result_pid

        end)
      |> Enum.map(fn(pid) ->
          receive do {^pid, result} ->
            result
          end
        end)
  end
    
end
