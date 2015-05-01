defmodule Gateway.Routing.RulesServer do
  use GenServer
  @name __MODULE__
  alias Gateway.Utilities.Stash

  ## Client API
  
  def start_link(stash_pid) do
    GenServer.start_link(@name, stash_pid, name: @name)
  end

  @doc false
  def add(rule) when is_map(rule) do
    GenServer.cast(@name, {:add, rule})
  end

  @doc false
  def remove(rule) when is_map(rule) do
    GenServer.cast(@name, {:remove, rule})
  end

  @doc false
  def get({key,value}) do
    GenServer.call(@name, {:get, {key,value}})
  end  
 
  @doc false
  def get do
    GenServer.call(@name, {:get})
  end

  @doc false
  def clear do
    GenServer.cast(@name, {:clear})
  end

  ## Server Callbacks

  def init(stash_pid) do
    {:ok, {Stash.retrieve(stash_pid), stash_pid}}
  end

  def handle_call({:get, {key,value}}, _from, {rules, stash_pid}) do
   {:reply, Enum.filter(rules, fn(x) -> x[key] == value end), {rules, stash_pid}}
  end
 
  def handle_call({:get}, _from, {rules, stash_pid}) do
    {:reply, rules, {rules, stash_pid}}
  end

  def handle_cast({:add,rule}, {rules, stash_pid}) do
    {:noreply, {[rule | rules], stash_pid}}
  end

  def handle_cast({:remove, rule}, {rules, stash_pid}) do
    {:noreply, {Enum.filter(rules, fn(x) -> x != rule end), stash_pid}}
  end

  def handle_cast({:clear}, {_rules, stash_pid}) do
    {:noreply, {[], stash_pid}}
  end

  def terminate(_reason, {rules, stash_pid}) do
    Stash.stash(stash_pid, rules)
  end

end
