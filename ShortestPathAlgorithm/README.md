# Chandry-Misra distributed shortest path algorithm #

This program implements the Chandry-Misra distributed shortest path algorithm. It involves a network of nodes representing different processes with relationships among them. Each node is defined with a structure that includes:

- A unique identifier (a label :a, :b, etc.),
- A set of properties or attributes (like {nil, 0, :infinity} which we’ll consider as metadata for now),
- A list of connections to other nodes, each specified with a target node and a weight.

Message types:
- start
- distUpdate
- ACK
- STOP

Each node will be represented by a labeled circle, such as :a, :b, etc.
Connections between nodes will be represented as directed edges with weights.
Edge weights will be annotated along each connection line to indicate the relation weight.

## Process network graph
![graph](https://github.com/user-attachments/assets/ba76e2cd-7434-4ebb-8da4-81efb67d67e8)
