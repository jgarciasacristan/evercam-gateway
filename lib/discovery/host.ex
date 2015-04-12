defmodule Gateway.Discovery.Host do
  @moduledoc "Scans individual hosts/devices using Nmap(1)"

  @doc "Scans network host (i.e. 192.168.1.50) for ports and 
  identifies services on those ports"
  def scan(host) do 
    command = "nmap -sV -oX - #{host}"
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

  # FIXME: same issues as parse_scan
  defp get_port_data(port) do
    {'port',port_info,[{_,_state,_},{_,service_info,_}]} = port
    port_info = Enum.into(port_info, %{})
    service_info = Enum.into(service_info, %{})
    Map.merge(port_info, service_info)
  end

end
