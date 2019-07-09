defmodule WebCAT.Import.Registry do
  use GenServer


  ## Client API

  @doc """
  Add a file to be imported
  """
  def add(path) do
    GenServer.cast(__MODULE__, {:add, path})
    Process.send(self(), :work, [])
  end

  @doc """
  Get the import results from the server
  """
  def results() do
    GenServer.call(__MODULE__, :results)
  end

  def queue() do
    GenServer.call(__MODULE__, :queue)
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{results: [], queue: :queue.new()}, name: __MODULE__)
  end

  ## Server API
  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:add, path}, %{queue: queue} = state) do
    {:noreply,
     Map.put(state, :queue, :queue.in(%{start_time: Timex.now(), path: path}, queue))}
  end

  @impl GenServer
  def handle_call(:results, _from, %{results: results} = state) do
    {:reply, results, state}
  end

  @impl GenServer
  def handle_call(:queue, _from, %{queue: queue} = state) do
    {:reply, :queue.to_list(queue), state}
  end

  @impl GenServer
  def handle_call(:clear, _from, _state) do
    {:reply, :ok, %{results: [], queue: :queue.new()}}
  end

  @impl GenServer
  def handle_info(:work, %{results: results, queue: queue} = state) do
    case :queue.out(queue) do
      {{:ok, _item}, out_queue} ->
        # Old import logic, no-op
        # result = WebCATWeb.Import.from_item(item)
        result = nil
        {:noreply, %{results: result ++ results, queue: out_queue}}

      _ ->
        {:noreply, state}
    end
  end
end
