defmodule WebCAT.Import.Registry do
  use GenServer

  ## Client API

  @doc """
  Add a file to be imported
  """
  def add(server, path) do
    Genserver.cast(server, {:add, path})
    Process.send(self(), :work)
  end

  @doc """
  Get the import results from the server
  """
  def results(server) do
    GenServer.call(server, :results)
  end

  def queue(server) do
    GenServer.call(server, :queue)
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{results: [], queue: :queue.new()})
  end

  ## Server API
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:add, path}, _from, %{queue: queue} = state) do
    {:noreply, Map.put(state, :queue, :queue.in(queue, path))}
  end

  @impl true
  def handle_call(:results, _from, %{results: results} = state) do
    {:reply, results, state}
  end

  @impl true
  def handle_call(:queue, _from, %{queue: queue} = state) do
    {:reply, :queue.to_list(queue), state}
  end

  @impl
  def handle_info(:work, _from, %{results: results, queue: queue} = state) do
    case :queue.out(queue) do
      {{:ok, path}, out_queue} ->
        result = WebCAT.Import.from_path(path)
        {:noreply, %{results: result ++ results, queue: out_queue}}

      _ ->
        {:noreply, state}
    end
  end
end
