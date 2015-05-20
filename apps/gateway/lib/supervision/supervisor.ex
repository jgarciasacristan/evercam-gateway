defmodule Gateway.Supervisor do  
  use Supervisor

  def start_link do 
    result = {:ok, sup} = Supervisor.start_link(__MODULE__,[])
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    # Start Stash for Rules
    {:ok, rules_stash} = Supervisor.start_child(sup, worker(Gateway.Utilities.Stash,[],id: :rules_stash))

    # Start Sub Supervisor for Rules
    Supervisor.start_child(sup, supervisor(Gateway.RoutingSupervisor, [rules_stash]))

     # Start Stash for Discovery
    {:ok, discovery_stash} = Supervisor.start_child(sup, worker(Gateway.Utilities.Stash,[], id: :discovery_stash))

    # Start Sub Supervisor for Discovery
    Supervisor.start_child(sup, supervisor(Gateway.DiscoverySupervisor, [discovery_stash]))

  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end

end
