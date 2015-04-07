defmodule Gateway.Discovery.Host do
  @moduledoc "Scans individual hosts/devices using Nmap(1)"

  @doc "Scans network host (i.e. 192.168.1.50) for ports and 
  identifies services on those ports"
  def scan(host) do 
    command = "nmap -sV -oX - " <> host
    %Porcelain.Result{out: output, status: status} = Porcelain.shell(command)
    output
      |> parse_scan
  end

  # Parses XML output of Nmap - no JSON from nmap yet sadly.
  # FIXME: This is fragile and ugly. Replace either using customised
  # SAX parser in erlsom, or create an XSL for Nmap XML to JSON
  defp parse_scan(xml) do
    scan_results = :erlsom.simple_form(xml)
    {:ok, {'nmaprun',_nmaprun,[_scaninfo,_verbosity,_debuglevel,
           {'host',_scantime,[_host_status,_host_address,_hostnames,
           {'ports',_,ports},_]},_runstats]},_} = scan_results
    
    ports 
      |> Enum.filter(&(elem(&1,0)=='port'))
      |> Enum.map(&(get_port_data(&1)))
 end

  defp get_port_data(port) do
    IO.inspect port
    {'port',[{_,port_id},{_,_protocol}],[{_,_state,_},{_,service,_}]} = port
    if Enum.count(service) == 4 do
      [_,_,{'servicefp',service_footprint},{'name',service_name}] = service
    else
      [_,_,{'name',service_name}] = service
    end
    %{port_id: to_string(port_id), service_name: to_string(service_name), service_footprint: service_footprint} 
  end

end
