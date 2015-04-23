defmodule Gateway.Routing.RulesTest do
  use ExUnit.Case, async: true
  alias Gateway.Routing.Rules
  alias Gateway.Routing.RulesServer  

  setup_all do
    # Start RulesServer and Stash manually
    {:ok, stash_pid} = Gateway.Utilities.Stash.start_link 
    Gateway.Routing.Rules.start_link(stash_pid) 
    :ok
  end

  test "Adding valid rule succeeds" do
    assert :ok == Rules.add(%{:gateway_port=>8080,:ip_address=>test_ip,:port=>80})
  end

  # Generates an IP that will work with at least one active Network interface on local machine
  # TODO: Discuss whether this is the right way to do this. Perhaps automation is not the answer.
  defp test_ip do
    alias Gateway.Utilities.Network, as: NetUtils
    
    NetUtils.get_interfaces
      # Filter out interfaces that have no ip address
      |> Enum.filter(fn(x) -> 
           NetUtils.get_interface_attribute(x, :addr) != nil
         end)
      # grab the first one
      |> Enum.at(0)
      # Get the ip address as a 4-tuple
      |> NetUtils.get_interface_attribute(:addr)
      # Increment the last value in the tuple
      |> (fn({oct1,oct2,oct3,oct4}) -> {oct1,oct2,oct3,oct4+1} end).()
      # Turn the result into a string
      |> NetUtils.to_ipstring
  end

end
