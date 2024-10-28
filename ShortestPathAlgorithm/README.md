# Chandry-Misra distributed shortest path algorithm #

This program implements the Chandry-Misra distributed shortest path algorithm. It involves a network of nodes representing different processes with relationships among them. Each node is defined with a structure that includes:

- A unique identifier (a label :a, :b, etc.),
- A set of properties or attributes (like {nil, 0, :infinity} which we’ll consider as metadata for now),
- A list of connections to other nodes, each specified with a target node and a weight.

### Message types:
- **start** (to initialise the whole graph with our starting knowledge)
- **distUpdate** (to update distances between nodes)
- **ACK** (to count if a node informed all of his neighbours and if they received it)
- **STOP** (if a node knows that all his neighbours are informed, he can go offline) 

Each node will be represented by a labeled circle, such as :a, :b, etc.
Connections between nodes will be represented as directed edges with weights.
Edge weights will be annotated along each connection line to indicate the relation weight.

## Process network graph
![graph](https://github.com/user-attachments/assets/ba76e2cd-7434-4ebb-8da4-81efb67d67e8)

## Messaging

### Check if new distance is shorter

```elixir
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
```

### Send ACK or STOP to predecessors
```elixir
# Send ACK or STOP to predecessors
if Enum.empty?(neighbours) do
  IO.puts("❌#{name}(#{id}) sends STOP as he doesn't have any neighbours.")
  send(Process.whereis(newPredecessor), {:STOP})
else
  IO.puts("💌 #{name}(#{id}) sends ACK to #{newPredecessor}")
  send(Process.whereis(newPredecessor), {:ACK})
end
```
