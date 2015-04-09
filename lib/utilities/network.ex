defmodule Gateway.Utilities.Network do

  @doc "Turns an erlang ip_address() into a string"
  def to_ipstring(addr) do
    addr
      |> :inet.ntoa
      |> to_string
  end

  @doc "Turns an erlang hwaddr (i.e. MAC) into a hex string with separator."
  def to_macstring(hwaddr) do
    hwaddr
      |> Enum.map(&(Hexate.encode(&1,2) <> ":"))
      |> to_string
      |> String.rstrip(?:)
  end

  @doc "Get a list of all the Network interfaces, discarding local loopback"
  def get_interfaces() do
    {:ok, interface_data} = :inet.getifaddrs()
    interface_data 
      |> Enum.filter(&(elem(&1,0) != 'lo'))    
  end

  @doc "Parse network interface data, transforming IP addresses and MAC Addresses 
  to string representations"
  def parse_interfaces(interfaces) do
    interfaces 
      |> Enum.map(&(parse_interface(&1)))
  end

  # Parse a specific interface. TODO: find a nicer way to replace elements.
  # TODO: Handle the Ipv6 addr which just happens to have the same bloody key-name
  defp parse_interface(interface) do
    {interface_name, elements} = interface
    {to_string(interface_name), Enum.map(elements, fn(x) -> replace_key(elements, elem(x,0)) end) }
  end

  # Implements the conversion based on key name
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

end
