defmodule Gateway.Utilities.Network do
  use Bitwise

  @doc "Turns an erlang ip_address() into a string"
  def to_ipstring(address) do
    address
      |> :inet.ntoa
      |> to_string
  end

  @doc "Turns a quad-dotted IPv4 string into an erlang ipaddress(), i.e. a 4-tuple."
  def to_ipaddress(address) do
    address
      |> String.split(".")
      |> Enum.map(fn(x) -> elem(Integer.parse(x),0) end)
      |> List.to_tuple
  end

  @doc "Turns an erlang ip_address() to a 32 bit decimal integer"
  def to_ipinteger(address) do
    {octet1, octet2, octet3, octet4} = address
    round((octet1*:math.pow(256,3)) + (octet2*:math.pow(256,2)) + (octet3*256) + octet4)
  end

  @doc "Determines if two IPv4 addresses with the same mask are on the same subnet.
  Example usage: same_subnet?({192,168,1,1},{192,168,23,254},{255,255,255,0})"
  def same_subnet?(ip_address1, ip_address2, mask) 
    when is_tuple(ip_address1) and is_tuple(ip_address2) and is_tuple(mask) do 
    
    ip_decimal1 = to_ipinteger(ip_address1)
    ip_decimal2 = to_ipinteger(ip_address2)
    mask_decimal = to_ipinteger(mask)

    (ip_decimal1 &&& mask_decimal) == (ip_decimal2 &&& mask_decimal)
  end

  @doc "Determines if two ip addresses with the same mask are on the same subnet.
  Example usage: same_subnet?(\"192.168.1.1\",\"192.168.23.254\",\"255.255.255.0\")"
  def same_subnet?(ip_address1, ip_address2, mask) 
    when is_binary(ip_address1) and is_binary(ip_address2) and is_binary(mask) do 
      
    same_subnet?(to_ipaddress(ip_address1), to_ipaddress(ip_address2), to_ipaddress(mask))
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
