defmodule Gateway.Supervisor do  
  use Supervisor

  def start_link do 
    result = {:ok, sup} = Supervisor.start_link(__MODULE__,[])
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    # Start Stash for Rules
    {:ok, stash} = Supervisor.start_child(sup, worker(Gateway.Utilities.Stash,[]))

    # Start Sub Supervisor for Rules
    Supervisor.start_child(sup, supervisor(Gateway.SubSupervisor, [stash]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end

end
