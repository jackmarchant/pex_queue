defmodule PriorityQueue do
  @moduledoc """
  A Queue that uses the First In, First Out (FIFO) method,
  unless provided with a function to prioritise items.

  An example of using the prioritise function might be to order
  from highest to lowest numbers, regardless of when they are added to the queue.
  For example, we have this queue:
  [7, 5, 2]
  When we add 6 to the queue, it results in:
  [7, 6, 5, 2]
  """

  use GenServer

  def start_link(prioritise \\ fn _, _ -> true end) do
    GenServer.start_link(__MODULE__, %{queue: [], prioritise: prioritise})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_call(:dequeue, _from, %{queue: []} = state), do: {:reply, nil, state}
  def handle_call(:dequeue, _from, %{queue: q} = state) do
    [h | tail] = Enum.reverse(q)
    queue = Enum.reverse(tail)
    {:reply, h, add_queue_to_state(queue, state)}
  end

  def handle_call({:enqueue, item}, _from, %{queue: q, prioritise: p} = state) do
    updated_queue = Enum.sort_by([item | q], fn i -> i end, p)
    {:reply, updated_queue, add_queue_to_state(updated_queue, state)}
  end

  def handle_call(:peek, _from, %{queue: q} = state) do
    [h | _] = Enum.reverse(q)
    {:reply, h, state}
  end

  def handle_call(:count, _from, %{queue: q} = state) do
    {:reply, length(q), state}
  end

  defp add_queue_to_state(queue, state) do
    Map.merge(state, %{queue: queue})
  end

  def enqueue(pid, item) do
    GenServer.call(pid, {:enqueue, item})
  end

  def dequeue(pid) do
    GenServer.call(pid, :dequeue)
  end

  def peek(pid) do
    GenServer.call(pid, :peek)
  end

  def count(pid) do
    GenServer.call(pid, :count)
  end
end
