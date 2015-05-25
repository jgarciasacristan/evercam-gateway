defmodule Gateway.Utilities.Stash do
  @moduledoc "A module designed to keep backup state of other processes"

  ## Client API

  def start_link do
    Agent.start(fn -> [] end)
  end

  @doc "Stashes any value. Replaces any value previously stashed."
  def stash(pid, value) do
    Agent.update(pid, fn -> value end)
  end

  @doc "Retrieves the value stashed."
  def retrieve(pid) do
    Agent.get(pid, &(&1))
  end

end
