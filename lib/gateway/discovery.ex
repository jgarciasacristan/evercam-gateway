defmodule Gateway.Discovery do
  alias Gateway.Discovery.Scan
  alias Gateway.Discovery.DiscoveryServer

  @doc "Starts DiscoveryServer which holds results
  in memory"
  def start_link(stash_pid) do
    result = DiscoveryServer.start_link(stash_pid)
    spawn fn-> start end
    result
  end

  @doc "Returns latest set of Discovery results"
  def results do
    DiscoveryServer.get   
  end

  # Scans network and stores results in memory
  defp start do 
    Scan.scan_test 
      |> DiscoveryServer.put
  end

end

