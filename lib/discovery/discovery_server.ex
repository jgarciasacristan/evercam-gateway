defmodule Gateway.Discovery.DiscoveryServer do
  use GenServer
  @name __MODULE__
  alias Gateway.Utilities.Stash

  ## Client API

  def start_link(stash_pid) do
    GenServer.start_link(@name, stash_pid, name: @name)
  end

  @doc false
  def get do
    GenServer.call(@name, {:get})
  end

  @doc false
  def put(scan_results) do
    GenServer.cast(@name, {:put, scan_results})
  end

  ## Server Callbacks
  def init(stash_pid) do
    {:ok, { Stash.retrieve(stash_pid), stash_pid } } 
  end

  def handle_call({:get},_from, {hosts, stash_pid}) do
    {:reply, hosts, {hosts, stash_pid}}
  end

  def handle_cast({:put, scan_results}, {hosts, stash_pid}) do
    {:noreply, {scan_results, stash_pid}}
  end
  
  def terminate(_reason, {hosts, stash_pid})  do
    Stash.stash(stash_pid, hosts)
  end

end
