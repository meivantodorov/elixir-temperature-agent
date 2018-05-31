defmodule API.Temperature do
  use Maru.Router
  plug Plug.Logger

  @root_dir "/sys/devices/w1_bus_master1"
  @one_wire "w1_slave"

  get "get_temperature" do
    ## With this implementation we assume that there is only one sensore

    [sensore_dir] =
      File.ls!(@root_dir)
      |> Enum.drop_while(fn(d) -> !String.match?(d, ~r/28-/) end)

    temperature =
      File.read!(Path.join(Path.join(@root_dir, sensore_dir), @one_wire))
      |> String.split("t=")
      |> Enum.at(1)
      |> String.replace("\n", "")
      |> String.to_integer()
      |> Kernel./(1)
      |> Kernel./(1000)

    conn |> text(temperature)

  end

end
