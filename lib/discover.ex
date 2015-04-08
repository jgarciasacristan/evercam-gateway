defmodule Gateway.Discover do
  alias Gateway.Discovery.Network
  alias Gateway.Discovery.Host
  alias Gateway.Utilities.ParallelMap

  @timeout 120000

  @doc "Returns a complete list of all network devices and associated data"
  def scan_basic do   
    # Get a list of all network hosts across all interfaces
    # format is [{ip,mac},{ip,mac},...]
    Network.scan_all()
      |> scan_hosts
  end

  @doc "Experimental use only. Scan beyond interface subnets. This will potentially 
  identify hosts that cannot be routed to. It could take a very long time - think days." 
  def scan_deep do
    ["", "192.0.0.0/24", "192.168.0.0/16", "169.254.0.0/16", "172.16.0.0/12"]
      |> Enum.reduce(fn(x,acc) -> Network.scan_all(x) ++ acc end)
      |> scan_hosts
  end

  @doc "Scans default IP addresses used by camera manufacturers. i.e. Hikvision: 192.0.0.64"
  def scan_default do
    Network.scan_all("192.0.0.64")
      |> scan_hosts
  end

  defp scan_hosts(hosts) do
    # Use a parallel map to run scans on every host concurrently. Add a two minute timeout 
    # for individual scans
    ParallelMap.pmap(hosts, fn(x) -> { elem(x,0), elem(x,1), Host.scan(elem(x,0)) } end, @timeout)
  end

end

