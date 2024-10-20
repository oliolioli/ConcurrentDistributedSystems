# ConcurrentDistributedSystems
Programming concurrent and distributed systems with Elixir

## Howto run Elixir programs locally in some minutes
1. Open Terminal
2. $ **mix new foo** (creates a scaffold for your program)
3. make sure to be in the specific workspace directory (where "mix.exs" has to be found)
4. Run the binaries with: $ **iex -S mix**
5. Now the iex-console opens. Run functions as the follows: **iex> Modulename.function** **e.g. iex> Foo.start**
6. use **iex> recompile** after every change to recompile

💬 Or much easier: just pack all your Elixir code into a **file *.exs** and **run** it with **$ elixir foo.exs**

## TokenRingPlus.exs: Message passing in a token node structure
Elixir program that creates a ring of N processes and sends M times a token with an associated
counter in the ring.

![image](https://github.com/user-attachments/assets/77be357c-5371-41ec-9e83-245e7e97ce37)

1. All ring processes have exactly the same code, except the starting process s that
provides a function start(N, M) to launch the application.
2. Each time a process p receives a token, p sends the token to its successor and
increments a local counter. It also prints the current value of the counter.
3. When there are no more tokens, each process terminates gracefully. Each
node write the last value of the counter into a file, together with its process
identifier and the identifier of its successor in the ring.

All processes in the ring to act as peers and spawn their successor, except for the last one that closes the ring.

Text above and the picture all taken from a Lecture at University of Fribourg 2024 by [Pascal Felber](https://www.unine.ch/pascal.felber), University of Neuchatel.

### Start: Spawn all the processes of the ring
```
# spawn all the processes
firstProcessID = spawn(fn -> TokenRing.createProcess(n, 0, m) end)         # second argument must be null, its the definition of the counter

# send m times a token into the ring (begin with the first (known) process
IO.puts "### Sending #{m} token(s) into the ring. 🚀 ###"

Enum.each(1..m, fn(_x) ->
  send(firstProcessID, :token)
end)
```

### Spawn next process(es) (recursively) in the ring
```
def createProcess(n, counter, m) do

  # Spawn next process in the ring (recursively)
  nextProcessID = spawn(fn -> createProcess(n - 1, counter, m) end)
```

### 
```
# Receive token (message ':token') and then send it further to the next process
receive do
  :token -> IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) received token.")
  
    # Pass the token to the next process (known because we spawned it (see above))
    send(nextProcessID, :token)
```

### Count tokens (recursively)
```
# Call the loop function again with the updated counter value
createProcess(n, new_counter, m)
```

### Log file
The following code provides a function **write_to_file** and generates respectively append to a log file:

```
defmodule FileWriter do
  # Function to write data to a file
  def write_to_file(file_path, data) do
    case File.open(file_path, [:append, :utf8]) do
      {:ok, file} ->
        # Writing the data to the file
        IO.write(file, data)
        
        # Closing the file
        File.close(file)

        {:ok, "Data written successfully!"}
        
      {:error, reason} ->
        {:error, "Failed to open the file: #{reason}"}
    end
  end
end
```

#### Example log file
```
Process[5] (#PID<0.106.0>) got all the 2 tokens and shut gracefully down. ✔️
Process[2] (#PID<0.114.0>) got all the 2 tokens and shut gracefully down. ✔️
Process[1] (#PID<0.115.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:00.964181Z: Process[0] (#PID<0.118.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941088Z: Process[5] (#PID<0.106.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941094Z: Process[4] (#PID<0.112.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941098Z: Process[3] (#PID<0.113.0>) got all the 2 tokens and shut gracefully down. ✔️
```

