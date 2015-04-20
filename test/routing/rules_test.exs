defmodule Gateway.Routing.RulesTest do
  use ExUnit.Case, async: true
  alias Gateway.Routing.Rules
  alias Gateway.Routing.RulesServer  

  @rule1 %{:gateway_port=>8080, :ip_address=>"192.168.1.101", :port=>80}
  @rule2 %{:gateway_port=>9080, :ip_address=>"172.16.0.21", :port=>8021}
  @replacement_rule %{:gateway_port=>8080, :ip_address=>"172.16.0.44", :port=>554}

  # Start RulesServer and Stash so testing can extend to them if need be
  setup_all do
    {:ok, stash_pid} = Gateway.Utilities.Stash.start_link
    Gateway.Routing.Rules.start_link(stash_pid)
    {:ok, stash: stash_pid}
   end

  test "that test works", context do 
    assert :ok == Rules.add(@rule1)
  end


end
