defmodule PriorityQueueTest do
  use ExUnit.Case
  doctest PriorityQueue

  describe "PriorityQueue (behaving as a normal queue)" do
    setup do
      {:ok, queue} = PriorityQueue.start_link()

      %{queue: queue}
    end

    test "it can add to the queue", %{queue: q} do
      assert ["hello"] == PriorityQueue.enqueue(q, "hello")
    end

    test "it can remove from the queue in FIFO order", %{queue: q} do
      PriorityQueue.enqueue(q, "hello")
      PriorityQueue.enqueue(q, "world")

      assert PriorityQueue.dequeue(q) == "hello"
    end

    test "removing from an empty queue returns nil", %{queue: q} do
      assert PriorityQueue.dequeue(q) == nil
    end

    test "it can peek at the head of the queue", %{queue: q} do
      PriorityQueue.enqueue(q, "hi there")
      PriorityQueue.enqueue(q, "hello again")

      peek = PriorityQueue.peek(q)

      # count should remain unchanged
      assert PriorityQueue.count(q) == 2
      assert peek == "hi there"
      assert PriorityQueue.count(q) == 2
    end
  end

  describe "PriorityQueue (with priority order)" do
    setup do
      {:ok, queue} = PriorityQueue.start_link(fn (new, item) -> new < item end)

      %{queue: queue}
    end

    test "it can add a priority when enqueuing", %{queue: q} do
      PriorityQueue.enqueue(q, 5)
      PriorityQueue.enqueue(q, 2)
      PriorityQueue.enqueue(q, 4)
      PriorityQueue.enqueue(q, 7)

      assert 7 == PriorityQueue.dequeue(q)
      assert 5 == PriorityQueue.dequeue(q)
      assert 4 == PriorityQueue.dequeue(q)
      assert 2 == PriorityQueue.dequeue(q)
    end
  end
end
