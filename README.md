# ConcurrentDistributedSystems
Programming concurrent and distributed systems with Elixir

## Message passing in a token node structure
**TokenRingPlus.exs:** 
Elixir program that creates a ring of N processes and sends M times a token with an associated
counter in the ring.

The following constraints must be fulfilled:

1. All ring processes have exactly the same code, except the starting process s that
provides a function start(N, M) to launch the application.
2. Each time a process p receives a token, p sends the associated counter incremented by
one to its successor. It also prints the value of the counter.
3. When there are no more tokens, each process terminates gracefully. Optionally, each
node can write the last value of the counter into a file, together with its process
identifier and the identifier of its successor in the ring.
