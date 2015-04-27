defmodule Gateway.Discovery.Host do
  @moduledoc "Scans individual hosts/devices using Nmap(1)"

  @doc "Scans network host (i.e. 192.168.1.50) for ports and 
  identifies services on those ports. -p- scans every port (removed for now). -sV is a service scan
  -oX is to output XML."
  def scan(host) do 
    command = "nmap -p1-10000 -sV -oX - #{host}"
    %Porcelain.Result{out: output, status: _status} = Porcelain.shell(command)
    output
      |> parse_scan
  end

  # Parses XML output of Nmap - no JSON from nmap yet sadly.
  # FIXME: This is fragile and ugly. Replace either using customised
  # SAX parser in erlsom, or create an XSL for Nmap XML to JSON
  # TODO: Examine DTD for Nmap XML see if I can use it to be more
  # accurate.
  defp parse_scan(xml) do
    scan_results = :erlsom.simple_form(xml)
      
    case scan_results do 
      {:ok, {'nmaprun',_nmaprun,[_scaninfo,_verbosity,_debuglevel,
           {'host',_scantime,[_host_status,_host_address,_hostnames,
           {'ports',_,ports},_]},_runstats]},_} ->
        ports 
          |> Enum.filter(&(elem(&1,0)=='port'))
          |> Enum.map(&(get_port_data(&1)))
      _->
        {:error, :processfailed}
      end
  end

  # FIXME: same issues as parse_scan
  defp get_port_data(port) do
    case port do
      {'port',port_info,[{_,_state,_},{_,service_info,_}]} ->
        port_info = Enum.into(port_info, %{})
        service_info = Enum.into(service_info, %{})
        Map.merge(port_info, service_info)
      _ ->
        %{}
    end
  end

end
