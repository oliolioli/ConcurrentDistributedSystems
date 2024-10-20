# ConcurrentDistributedSystems
Programming concurrent and distributed systems with Elixir

## TokenRingPlus.exs: Message passing in a token node structure
Elixir program that creates a ring of N processes and sends M times a token with an associated
counter in the ring.

1. All ring processes have exactly the same code, except the starting process s that
provides a function start(N, M) to launch the application.
2. Each time a process p receives a token, p sends the token to its successor and
increments a local counter. It also prints the current value of the counter.
3. When there are no more tokens, each process terminates gracefully. Each
node write the last value of the counter into a file, together with its process
identifier and the identifier of its successor in the ring.

All processes in the ring to act as peers and spawn their successor, except for the last one that closes the ring.

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

```
Process[5] (#PID<0.106.0>) got all the 2 tokens and shut gracefully down. ✔️
Process[2] (#PID<0.114.0>) got all the 2 tokens and shut gracefully down. ✔️
Process[1] (#PID<0.115.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:00.964181Z: Process[0] (#PID<0.118.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941088Z: Process[5] (#PID<0.106.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941094Z: Process[4] (#PID<0.112.0>) got all the 2 tokens and shut gracefully down. ✔️
2024-10-19 18:58:39.941098Z: Process[3] (#PID<0.113.0>) got all the 2 tokens and shut gracefully down. ✔️
```

