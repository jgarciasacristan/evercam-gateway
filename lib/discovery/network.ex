defmodule Gateway.Discovery.Network do
  @moduledoc "Scans LAN for devices, using arp-scan(1)"
  alias Gateway.Utilities.Network, as: NetUtils

  @doc "Scan specified target network (i.e. 192.168.0.1-192.168.100.255) 
  on specified NIC. Default target is local network." 
  def scan(interface, target \\ "--localnet", arp_scan_options \\ "") do
    command = "sudo arp-scan #{arp_scan_options} --interface=#{interface} #{target}"
    %Porcelain.Result{out: output, status: status} = Porcelain.shell(command)
    output 
      |> parse_scan
      |> Enum.uniq
      |> Enum.map(&(List.to_tuple(&1)))
  end

  @doc "Scan all NICs for target network. Default is local network 
  for each interface."
  def scan_all(target \\ "--localnet", arp_scan_options \\ "") do
    NetUtils.get_interfaces
      |> Enum.map(&(elem(&1,0)))
      |> Enum.map(&(scan(&1,target,arp_scan_options))) 
      |> List.flatten()
  end

  @doc "Get data for local networks"
  def get_networks() do
    NetUtils.get_interfaces
      |> NetUtils.parse_interfaces
  end

  # Parse arp-scan results into an idiomatic format
  defp parse_scan(results) do 
    Regex.scan(~r/(?<ip>(?:\d{1,3}\.){3}\d{1,3})\t(?<mac>(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2})/, results, capture: :all_names)
  end

end
