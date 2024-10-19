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
3. When there are no more tokens, each process terminates gracefully. Each
node write the last value of the counter into a file, together with its process
identifier and the identifier of its successor in the ring.

```
Process[5] (#PID<0.106.0>) got all the 2 tokens and shut gracefully down. ✔️
Process[2] (#PID<0.114.0>) got all the 2 tokens and shut gracefully down. ✔️
Process[1] (#PID<0.115.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:00.964181Z: Process[0] (#PID<0.118.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941088Z: Process[5] (#PID<0.106.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941094Z: Process[4] (#PID<0.112.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941098Z: Process[3] (#PID<0.113.0>) got all the 2 tokens and shut gracefully down. ✔️
```

