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

Paragraph above and the picture all taken from a Lecture at University of Fribourg 2024 by [Pascal Felber](https://www.unine.ch/pascal.felber), University of Neuchatel.

### Start: Spawn all the processes of the ring
```elixir
# spawn all the processes
firstProcessID = spawn(fn -> TokenRing.createProcess(n, 0, m) end)         # second argument must be null, its the definition of the counter

# send m times a token into the ring (begin with the first (known) process
IO.puts "### Sending #{m} token(s) into the ring. 🚀 ###"

Enum.each(1..m, fn(_x) ->
  send(firstProcessID, :token)
end)
```

### Spawn next process(es) (recursively) in the ring
```elixir
def createProcess(n, counter, m) do

  # Spawn next process in the ring (recursively)
  nextProcessID = spawn(fn -> createProcess(n - 1, counter, m) end)
```

### Know your own PID when you're a service
```elixir
inspect(self()

# will print something like '(#PID<0.1261.0>)'
```

### Receive token messages and send them to next process
```elixir
# Receive token (message ':token') and then send it further to the next process
receive do
  :token -> IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) received token.")
  
    # Pass the token to the next process (known because we spawned it (see above))
    send(nextProcessID, :token)
```

### Count tokens (recursively)
```elixir
# Call the loop function again with the updated counter value
createProcess(n, new_counter, m)
```

### Shutting down process gracefully (after receiving all tokens)
```elixir
# Increment the counter when receiving :token
new_counter = counter + 1
...
# Check if we got all the tokens
if new_counter == m do
  Process.exit(self(), :normal)
```

## Program running 10'000 processes and 10 tokens: stdout  
```
Process[9970] (#PID<0.14824.0>) received token.
Process[9965] (#PID<0.9746.0>) got: 5 tokens.
Process[9963] (#PID<0.8773.0>) got: 3 tokens.
Process[9966] (#PID<0.10370.0>) got: 6 tokens.
Process[9953] (#PID<0.153.0>) got: 1 tokens.
Process[9952] (#PID<0.154.0>) received token.
Process[9973] (#PID<0.13460.0>) ➡ Got all the tokens and can shutdown gracefully. ✔
Process[9964] (#PID<0.10043.0>) received token.
Process[9962] (#PID<0.9012.0>) received token.
Process[9972] (#PID<0.13861.0>) ➡ Got all the tokens and can shutdown gracefully. ✔
```

### Checking specific Processes with grep
**elixir TokenRingPlus.exs | grep -F 'Process[10'**
```
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 1 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 2 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 3 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 4 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 5 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 6 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 7 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 8 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 9 tokens.
Process[10] (#PID<0.106.0>) received token.
Process[10] (#PID<0.106.0>) got: 10 tokens.
Process[10] (#PID<0.106.0>) ➡ Got all the tokens and can shutdown gracefully. ✔
```

### Log file
The following code provides a function **write_to_file** and generates respectively append to a log file:

```elixir
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

#### Write status into log file
```elixir
current_datetime = DateTime.utc_now()
timestamp = DateTime.to_string(current_datetime)
FileWriter.write_to_file("TokenRing.log", "#{timestamp}: Process[#{n}] (#{inspect(self())}) got all the #{m} tokens and shut gracefully down. ✔️ Successor: #{to_string(n-1)}\n")
IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) ➡️ Got all the tokens and can shutdown gracefully. ✔️")
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
