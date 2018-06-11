defmodule API.Temperature do
  use Maru.Router
  plug(Plug.Logger)

  @root_dir "/sys/devices/w1_bus_master1"
  @one_wire "w1_slave"

  @no_sensores_found "No sensores found"
  @general_error "General error"

  get("get_temperature", do: process(conn))

  def process(conn) do
    with {:ok, all_sensores} <- get_all_sensores(),
         {:ok, all_temperatures} <- get_all_temperatures(all_sensores),
         {:ok, sensores_responses} <- build_sensores_responses(all_temperatures) do
      json(conn, build_general_response(:ok, :ok, sensores_responses))
    else
      {:error, reason} ->
        json(conn, build_general_response(:error, reason, []))
    end
  end

  @spec get_all_sensores() :: {:ok, list()} | {:error, term()}
  def get_all_sensores() do
    all_folders = File.ls!(@root_dir)

    case Enum.filter(all_folders, fn d -> String.starts_with?(d, "28-") end) do
      [] ->
        {:error, @no_sensores_found}

      [_ | _] = all_sensores ->
        {:ok, all_sensores}

      _ ->
        {:error, @general_error}
    end
  end

  @spec get_all_temperatures(list()) :: list()
  def get_all_temperatures(sensores), do: get_all_temperatures(sensores, [])

  @spec get_all_temperatures(list(), list()) :: {:ok, list()} | {:error, term()}
  def get_all_temperatures([sensore | sensores], acc) do
    case get_temperature(sensore) do
      {:ok, temperature} ->
        get_all_temperatures(sensores, [{sensore, {:ok, temperature}} | acc])

      {:error, _} ->
        get_all_temperatures(sensores, [{sensore, {:error, :invalid_data}} | acc])
    end
  end

  def get_all_temperatures([], [_ | _] = acc), do: {:ok, acc}
  def get_all_temperatures(_, _), do: {:error, @no_sensores_found}

  @spec get_temperature(String.t()) :: {:ok, float()} | {:error, :invalid_data}
  def get_temperature(sensore_dir) do
    try do
      temperature =
        File.read!(Path.join(Path.join(@root_dir, sensore_dir), @one_wire))
        |> String.split("t=")
        |> Enum.at(1)
        |> String.replace("\n", "")
        |> String.to_integer()
        |> Kernel./(1)
        |> Kernel./(1000)

      {:ok, temperature}
    rescue
      _ ->
        {:error, :invalid_data}
    end
  end

  @spec build_sensores_responses(list()) :: {:ok, list(map())}
  def build_sensores_responses(all_responses) do
    {:ok,
     Enum.reduce(all_responses, [], fn {sensore, response}, acc ->
       [build_sensore_response(sensore, response) | acc]
     end)}
  end

  @spec build_sensore_response(String.t(), {:ok | :error, term()}) :: map()
  defp build_sensore_response(sensore, {status, data}) do
    %{status: status, sensore_id: sensore, sensore_resp: data, timestamp: get_current_time()}
  end

  @spec build_general_response(:ok | :error, term(), list(map())) :: map()
  def build_general_response(:error, resp_msg, sensores) do
    general_response(:error, resp_msg, sensores)
  end

  def build_general_response(:ok, resp_msg, sensores) do
    {status, resp_msg} =
      if Enum.all?(sensores, fn %{status: status} -> status == :ok end) do
        {:ok, resp_msg}
      else
        {:error, "Invalid data from one or more sensores"}
      end

    general_response(status, resp_msg, sensores)
  end

  def general_response(status, resp_msg, sensores) do
    %{response: %{status: status, resp_msg: resp_msg, sensores: sensores}}
  end

  defp get_current_time() do
    Calendar.DateTime.now!("Europe/Helsinki") |> Calendar.DateTime.Format.unix()
  end
end
