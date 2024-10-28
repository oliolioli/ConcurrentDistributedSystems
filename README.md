# ConcurrentDistributedSystems
Programming concurrent and distributed systems with Elixir.

### Howto run Elixir programs locally in some minutes
1. Open Terminal
2. $ **mix new foo** (creates a scaffold for your program)
3. make sure to be in the specific workspace directory (where "mix.exs" has to be found)
4. Run the binaries with: $ **iex -S mix**
5. Now the iex-console opens. Run functions as the follows: **iex> Modulename.function** **e.g. iex> Foo.start**
6. use **iex> recompile** after every change to recompile

💬 Or much easier: just pack all your Elixir code into a **file *.exs** and **run** it with **$ elixir foo.exs**


## Read about the different projects:
**Message passing in a token ring like node structure:** 
https://github.com/oliolioli/ConcurrentDistributedSystems/tree/main/TokenRingMessaging

**Implementation of a Chandry-Misra distributed shortest** path algorithm: https://github.com/oliolioli/ConcurrentDistributedSystems/tree/main/ShortestPathAlgorithm
