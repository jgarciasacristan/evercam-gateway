defmodule Gateway.Utilities.ParallelTest do
  use ExUnit.Case
  alias Gateway.Utilities.Parallel

  test "Elements are returned in sequence even when mapped function
  runs for arbitrary length of time" do
    testfun = fn(x) -> :timer.sleep(100*x)
                        x * 2 
                        end   
    assert [4,3,2,1] |> Parallel.map(testfun, 500) == [8,6,4,2]
  end

  test "Mapped element is returned as an error tuple if process
  fails or times out" do
    testfun = fn(x) -> :timer.sleep(100*x)
                        1 / x 
                        end   
    assert [10,4,5,1,0] |> Parallel.map(testfun, 500) 
        == [{:error, :processfailed}, 0.25,0.2,1,{:error, :processfailed}]
  end 
end
