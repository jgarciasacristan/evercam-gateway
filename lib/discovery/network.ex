defmodule Gateway.Discovery.Network do
  @moduledoc "Scans LAN for devices, using arp-scan(1)"

  @doc "Scan specified target network (i.e. 192.168.0.1-192.168.100.255) 
  on specified NIC. Default target is local network." 
  def scan(interface, target \\ "--localnet", arp_scan_options \\ "") do
    command = "sudo arp-scan " <> arp_scan_options <> " --interface " <> 
              interface <> " " <> target
    %Porcelain.Result{out: output, status: status} = Porcelain.shell(command)
    output |> parse_scan
  end

  @doc "Scan all NICs for target network. Default is local network 
  for each interface."
  def scan_all(target \\ "--localnet", arp_scan_options \\ "") do
    get_interfaces |> Enum.map(&(scan(&1,target,arp_scan_options))) |> List.flatten()
  end

  # Parse arp-scan results into an idiomatic format
  defp parse_scan(results) do 
    Regex.scan(~r/(?<ip>(?:\d{1,3}\.){3}\d{1,3})\t(?<mac>(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2})/, results, capture: :all_names)
  end

  # Get a list of all the Network interfaces, discard local loopback
  defp get_interfaces() do
    {:ok, interface_data} = :inet.getifaddrs()
    Enum.filter_map(interface_data, &(elem(&1,0) != 'lo'), &(to_string elem(&1,0)))    
  end

end
