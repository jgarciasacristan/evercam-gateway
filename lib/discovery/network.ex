defmodule Gateway.Discovery.Network do
  @moduledoc "Scans LAN for devices, using arp-scan(1)"

  @doc "Scan specified target network (i.e. 192.168.0.1-192.168.100.255) 
  on specified NIC. Default target is local network." 
  def scan(interface, target \\ "--localnet", arp_scan_options \\ "") do
    command = "sudo arp-scan " <> arp_scan_options <> " --interface " <> 
              interface <> " " <> target
    %Porcelain.Result{out: output, status: status} = Porcelain.shell(command)
    output 
      |> parse_scan
      |> Enum.map(&(List.to_tuple(&1)))
  end

  @doc "Scan all NICs for target network. Default is local network 
  for each interface."
  def scan_all(target \\ "--localnet", arp_scan_options \\ "") do
    get_interfaces
      |> Enum.map(&(to_string elem(&1,0)))
      |> Enum.map(&(scan(&1,target,arp_scan_options))) 
      |> List.flatten()
  end

  @doc "Get data for local networks"
  def get_networks() do
    get_interfaces
      |> parse_interfaces
  end

  # Parse arp-scan results into an idiomatic format
  defp parse_scan(results) do 
    Regex.scan(~r/(?<ip>(?:\d{1,3}\.){3}\d{1,3})\t(?<mac>(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2})/, results, capture: :all_names)
  end

  # Parse interface data. Transform IP addresses and MAC Addresses to string representations
  defp parse_interfaces(interfaces) do
    interfaces 
      |> Enum.map(&(parse_interface(&1)))
  end

  # Parse a specific interface. TODO: find a nicer way to replace elements.
  # TODO: Handle the Ipv6 addr which just happens to have the same bloody key-name
  defp parse_interface(interface) do
    {interface_name, elements} = interface
    {to_string(interface_name), Enum.map(elements, fn(x) -> replace_key(elements, elem(x,0)) end) }
  end

  defp replace_key(elements, key) do
    case key do
      :addr ->
        {key, to_ipstring(elements[key])}
      :netmask ->
        {key, to_ipstring(elements[key])}
      :broadaddr ->
        {key, to_ipstring(elements[key])}
      :hwaddr ->
        {key, to_macstring(elements[key])}
      _->
        {key, elements[key]}
    end
  end

  # turns an erlang ip_address() into a string
  defp to_ipstring(addr) do
    addr
      |> :inet.ntoa
      |> to_string
  end

  # hwaddr (i.e. mac) is represented as a list of decimal integers. Turn into hex string with separator.
  defp to_macstring(hwaddr) do
    hwaddr
      |> Enum.map(&(Hexate.encode(&1,2) <> ":"))
      |> to_string
      |> String.rstrip(?:)
  end

  # Get a list of all the Network interfaces, discard local loopback
  defp get_interfaces() do
    {:ok, interface_data} = :inet.getifaddrs()
    interface_data 
      |> Enum.filter(&(elem(&1,0) != 'lo'))    
  end

end
