defmodule Gateway.Utilities.External do

  def shell(command) do
    Porcelain.shell(command, [out: :string, err: :string])
  end

  def shell(command, opts \\ [out: :string, err: :string]) do
    Porcelain.shell(command, opts)
  end

end
