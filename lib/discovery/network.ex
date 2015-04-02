defmodule Gateway.Discovery.Network do
  @moduledoc "Scans LAN for devices, using arp-scan(1)"

  @doc "Scan specified target network (i.e. 192.168.0.1-192.168.100.255) 
  on specified NIC. Default target is local network." 
  def scan(interface, target \\ "--localnet", arp_scan_options \\ "") do
    alias Porcelain.Result
    command = "sudo arp-scan " <> arp_scan_options <> " --interface " <> 
              interface <> " " <> target
    %Result{out: output, status: status} = Porcelain.shell(command)
    parse_scan(output)
  end

  # Parse arp-scan results into an idiomatic format
  defp parse_scan(results) do 
    results
  end

end
