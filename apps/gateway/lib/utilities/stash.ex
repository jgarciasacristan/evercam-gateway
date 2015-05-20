defmodule Gateway.Utilities.Stash do
  @moduledoc "A module designed to keep backup state of other processes"
  use GenServer

  ## Client API

  def start_link do
    GenServer.start_link(__MODULE__,[])
  end

  @doc "Stashes any value. Replaces any value previously stashed."
  def stash(pid, value) do
    GenServer.cast(pid, {:stash, value})
  end

  @doc "Retrieves the value stashed."
  def retrieve(pid) do
    GenServer.call(pid, :retrieve)
  end

  ## Server Callbacks

  def handle_call(:retrieve, _from, current_value) do
    {:reply, current_value, current_value}
  end

  def handle_cast({:stash, value}, _current_value) do
    {:noreply, value}
  end

end
