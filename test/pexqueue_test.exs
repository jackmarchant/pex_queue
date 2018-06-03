defmodule PexQueueTest do
  use ExUnit.Case
  doctest PexQueue

  describe "PexQueue (behaving as a normal queue)" do
    setup do
      {:ok, queue} = PexQueue.start_link()

      %{queue: queue}
    end

    test "it can add to the queue", %{queue: q} do
      assert ["hello"] == PexQueue.enqueue(q, "hello")
    end

    test "it can remove from the queue in FIFO order", %{queue: q} do
      PexQueue.enqueue(q, "hello")
      PexQueue.enqueue(q, "world")

      assert PexQueue.dequeue(q) == "hello"
    end

    test "removing from an empty queue returns nil", %{queue: q} do
      assert PexQueue.dequeue(q) == nil
    end

    test "it can peek at the head of the queue", %{queue: q} do
      PexQueue.enqueue(q, "hi there")
      PexQueue.enqueue(q, "hello again")

      peek = PexQueue.peek(q)

      # count should remain unchanged
      assert PexQueue.count(q) == 2
      assert peek == "hi there"
      assert PexQueue.count(q) == 2
    end
  end

  describe "PexQueue (with priority order)" do
    setup do
      {:ok, queue} = PexQueue.start_link(fn (new, item) -> new < item end)

      %{queue: queue}
    end

    test "it can add a priority when enqueuing", %{queue: q} do
      PexQueue.enqueue(q, 5)
      PexQueue.enqueue(q, 2)
      PexQueue.enqueue(q, 4)
      PexQueue.enqueue(q, 7)

      assert 7 == PexQueue.dequeue(q)
      assert 5 == PexQueue.dequeue(q)
      assert 4 == PexQueue.dequeue(q)
      assert 2 == PexQueue.dequeue(q)
    end
  end
end
