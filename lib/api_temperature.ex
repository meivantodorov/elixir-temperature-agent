defmodule API.Temperature do
  use Maru.Router
  plug Plug.Logger

  @root_dir "/sys/devices/w1_bus_master1"
  @one_wire "w1_slave"

  @no_sensores_found "no sensores found"
  @general_error "something when wrong"

  get "get_temperature", do: process(conn)

  def process(conn) do
    with {:ok, all_sensores} <- get_all_sensores(),
         {:ok, temperature} <- get_temperature(all_sensores),
         {:ok, response} <- build_response(conn, temperature) do
      {:ok, response}
      response
    else
      {:error, reason} ->
        build_response(conn, reason)
    end
  end

  @spec get_all_sensores() :: {:ok, list()} | {:error, term()}
  defp get_all_sensores() do
    all_folders = File.ls!(@root_dir)
    case Enum.drop_while(all_folders, fn(d) -> !String.match?(d, ~r/28-/) end) do
      [] ->
        {:error, @no_sensores_found}

      [_ | _] = all_sensores ->
        {:ok, all_sensores}

        _ ->
        {:error, @general_error}
    end
  end

  @spec get_temperature(list()) :: {:ok, float()} | {:error, term()}
  defp get_temperature(sensores_dir) do
    try do
      File.read!(Path.join(Path.join(@root_dir, sensores_dir), @one_wire))
      |> String.split("t=")
      |> Enum.at(1)
      |> String.replace("\n", "")
      |> String.to_integer()
      |> Kernel./(1)
      |> Kernel./(1000)
      |> validate_temperature()
    rescue
      _ ->
        {:error, "could not get the temperature"}
    end
  end

  @spec validate_temperature(float() | term()) :: {:ok, float()} | {:error, term()}
  defp validate_temperature(temp) when is_float(temp), do: {:ok, temp}
  defp validate_temperature(_), do: {:error, "invalid temperature"}

  defp build_response(conn, temperature) when is_float(temperature) do
    {:ok, json(conn, %{status: :ok,
                       response: temperature,
                       timestamp: :os.system_time(:millisecond)})}
  end

  defp build_response(conn, error) do
    {:error, json(conn, %{status: :error,
                          response: error,
                          timestamp: :os.system_time(:millisecond)})}
  end

end
