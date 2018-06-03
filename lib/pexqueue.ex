defmodule PexQueue do
  @moduledoc """
  A Queue that uses the First In, First Out (FIFO) method,
  unless provided with a function to prioritise items.

  An example of using the prioritise function might be to order
  from highest to lowest numbers, regardless of when they are added to the queue.
  For example, we have this queue:

  ```elixir
  {:ok, pid} = PexQueue.start_link(fn first, second -> first < second end)
  PexQueue.enqueue(pid, 2)
  PexQueue.enqueue(pid, 7)
  PexQueue.enqueue(pid, 5)
  ```
  **Queue state:** `[7, 5, 2]`

  When we add 6 to the queue, it results in:
  ```elixir
  PexQueue.enqueue(pid, 6)
  ```
  **Queue state:** `[7, 6, 5, 2]`

  This is in contrast to a queue with a provided prioritisation function,
  which would return items in the order they were added.

  ```elixir
  {:ok, pid} = PexQueue.start_link(fn first, second -> first < second end)
  PexQueue.enqueue(pid, 2)
  PexQueue.enqueue(pid, 7)
  PexQueue.enqueue(pid, 5)

  # Queue state: [2, 5, 7]

  PexQueue.dequeue(pid) # 2
  PexQueue.dequeue(pid) # 5
  PexQueue.dequeue(pid) # 7

  ```
  """

  use GenServer

  @doc """
  Adds an item to the queue
  """
  def enqueue(pid, item) do
    GenServer.call(pid, {:enqueue, item})
  end

  @doc """
  Removes an item from the queue
  """
  def dequeue(pid) do
    GenServer.call(pid, :dequeue)
  end

  @doc """
  Returns the first item in the queue, without altering the queue state
  """
  @spec peek(pid()) :: any()
  def peek(pid) do
    GenServer.call(pid, :peek)
  end

  @doc """
  Returns the length of the queue
  """
  @spec count(pid()) :: integer()
  def count(pid) do
    GenServer.call(pid, :count)
  end

  @doc """
  Start a new Priority Queue
  """
  @spec start_link(fun()) :: {:ok, pid()}
  def start_link(prioritise \\ fn _, _ -> true end) do
    GenServer.start_link(__MODULE__, %{queue: [], prioritise: prioritise})
  end

  @doc false
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
end
