defmodule Gateway.Discover do
   @doc "Returns a complete list of all network devices and associated data"
  
  def run do
    @alias Gateway.Discovery.Network
    @alias Gateway.Discovery.Host
    @alias Gateway.Utilities.ParallelMap
   
    # Get a list of all network hosts across all interfaces
    # format is [{ip,mac},{ip,mac},...]
    hosts = Network.scan_all()

    # Use a parallel map to run scans on every host concurrently
    ParallelMap.pmap(hosts, fn(x) -> { elem(x,0), elem(x,1), Host.scan(elem(x,0)) } end, 60000)

  end

end

