defmodule Gateway do

  def start(_type, _args) do
    {:ok, _pid} = Gateway.Supervisor.start_link
  end

end
