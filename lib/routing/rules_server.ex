defmodule Gateway.Routing.RulesServer do
  use GenServer
  @name __MODULE__

  ## Client API
  
  def start_link do
    GenServer.start_link(@name, :ok, name: @name)
  end

  @doc "Stores a rule"
  def add(rule) when is_map(rule) do
    GenServer.cast(@name, {:add, rule})
  end

  @doc "Removes a rule from storage"
  def remove(rule) when is_map(rule) do
    GenServer.cast(@name, {:remove, rule})
  end

  @doc "Gets a rule or rules by key-value"
  def get({key,value}) do
    GenServer.call(@name, {:get, {key,value} })
  end  
 
  @doc "Gets all rules"
  def get do
    GenServer.call(@name, {:get})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:get, {key,value} }, _from, rules) do
    {:reply, Enum.filter(rules, fn(x) -> x[key] == value end), rules}
  end
 
  def handle_call({:get}, _from, rules) do
    {:reply, rules, rules}
  end

  def handle_cast({:add,rule},rules) do
    {:noreply, [rule | rules]}
  end

  def handle_cast({:remove, rule}, rules) do
    {:noreply, Enum.filter(rules, fn(x) -> x != rule end)}
  end

end
