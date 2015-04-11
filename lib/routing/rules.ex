defmodule Gateway.Routing.Rules do
  @moduledoc "Controls use of iptables(8) for dynamically adding and removing
  routing rules. These rules direct traffic from the Gateway to other LAN devices."

  @doc "Uses iptables to add a rule. Needs interface ip so that it can set
  the source of the traffic to the Gateway interface that is on the same subnet as
  the device."
  def add_rule(interface_ip_address, gateway_port, host_ip_address, host_port) do
    pre_routing = "-t nat -A PREROUTING -p tcp --dport #{gateway_port} -j DNAT --to-destination #{host_ip_address}:#{host_port}"
    post_routing = "-t nat -A POSTROUTING -p tcp -d #{host_ip_address} --dport #{host_port} -j SNAT --to-source #{interface_ip_address}"
  
    %Porcelain.Result{out: output, status: status} = Porcelain.shell("sudo iptables #{pre_routing}") 
    # prevent the post-route being added if pre-route failed. Otherwise buggy networking may ensue.
    if status = 0 do
      %Porcelain.Result{out: output, status: status} = Porcelain.shell("sudo iptables #{post_routing}") 
    end
    status
  end

end
