# Chandy-Misra shortest path algorithm
defmodule ChandyMisraSkeleton do

  def deploy(topology) do
    # Create network (use registered names for communication)
    Process.register(spawn(__MODULE__, :cm, [{1, :a}, {nil, 0, :infinity}, [{:b,5}, {:c,1}, {:e,4}]]), :a)
    Process.register(spawn(__MODULE__, :cm, [{2, :b}, {nil, 0, :infinity}, []]), :b)
    Process.register(spawn(__MODULE__, :cm, [{3, :c}, {nil, 0, :infinity}, [{:e,2}, {:d,1}]]), :c)
    Process.register(spawn(__MODULE__, :cm, [{4, :d}, {nil, 0, :infinity},
      cond do
        # Cycle (not including source)
        topology == 1 -> [{:f,-5}]
        # Cycle (including source)
        topology == 2 -> [{:f,5}, {:a,-3}]
        # No cycle
        true -> [{:f,5}]
      end]), :d)
    Process.register(spawn(__MODULE__, :cm, [{5, :e}, {nil, 0, :infinity}, [{:b,1}, {:d,5}]]), :e)
    Process.register(spawn(__MODULE__, :cm, [{6, :f}, {nil, 0, :infinity}, [{:b,6}, {:g,2}]]), :f)
    Process.register(spawn(__MODULE__, :cm, [{7, :g}, {nil, 0, :infinity}, [{:d,2}]]), :g)
   
    # Start first process a
    send(:a, {:start})
    :timer.sleep(1000)
  end

  # Each process has an identifier (id) and a name (name).
  # We use names instead of Elixir pids to simplify communication and have readable logs.
  # Identifiers are used to mirror the original algorithm and identify the source (process 1).
  # Neighbours denote successors, i.e., outgoing edges only, not incoming ones.

  def cm({id, name}, {pred, num, d}, neighbours) do
    
    # Print status information so that we know who and where we are.
    # IO.puts("Status: #{name}(#{id}), predecessors: #{pred}, num=#{num}, distance=#{d}, neighbours: #{inspect(neighbours)}")
    IO.puts("💬 #{name}(#{id}), dist=#{d} via #{pred}, having num=#{num}")
    
    receive do
      # Initialise first process a and begin process
      {:start} -> 
        # Iterate through all neighbours and send them (the new) distance information
        Enum.each(neighbours, fn {neighbourName, dist} ->
         send(Process.whereis(neighbourName), {:distUpdate, name, dist})
         IO.puts("⏩#{name}(#{id}) sent (distance=#{dist}, predecessor=a) --> #{neighbourName}")
        end)
       

      {:distUpdate, newPredecessor, newDist} -> 
        IO.puts("🔃#{name}(#{id}) received new distance = #{newDist} from predecessor: #{newPredecessor}")

        # Send ACK or STOP to predecessors
        if Enum.empty?(neighbours) do
          IO.puts("❌#{name}(#{id}) sends STOP as he doesn't have any neighbours.")
          send(Process.whereis(newPredecessor), {:STOP})
        else
          IO.puts("💌 #{name}(#{id}) sends ACK to #{newPredecessor}")
          send(Process.whereis(newPredecessor), {:ACK})
        end

        # Check if new distance is shorter. If so, update myself and send messages to my neighbours
        if newDist < d do
          # Iterate through all neighbours and send them (the new) distance information
          Enum.each(neighbours, fn {neighbourName, neighbourDist} ->
            # Add new updated distance of node plus the next neighbours distance together and pass it on
            newNeighbourDist = newDist + neighbourDist
            send(Process.whereis(neighbourName), {:distUpdate, name, newNeighbourDist})

            # Write some status info
            IO.puts("📤 #{name}(#{id}) sent (distance=#{newNeighbourDist}, predecessor=a) --> #{neighbourName}")
          end) 

           # Update node (predecessor, num (by counting neighbours) and distance) if we found a smaller distance
           cm({id, name}, {newPredecessor, length(neighbours), newDist}, neighbours)
        end
        
         # Receiving ACK and then trying to decrement num
        {:ACK} ->
         IO.puts("🆗Node #{name}(#{id}) received ACK.")
         newNum = num - 1

         #if num is zero (again) by any chance, then send STOP signal to predecessor
         if newNum === 0 do
          send(Process.whereis(pred), {:STOP})
         end
         cm({id, name}, {pred, newNum, d}, neighbours)

        {:STOP} ->
          IO.puts("🏁 #{name}(#{id}) received STOP signal finally")
        
        # Update node also when no message is received 
        # cm({id, name}, {pred, num, d}, neighbours)
     end

    cm({id, name}, {pred, num, d}, neighbours)

  end

  def start() do
    IO.puts("Deploying")
    # Deploy specific topologies
    deploy(0)
    IO.puts("Starting")
  end

end

ChandyMisraSkeleton.start()
