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

defmodule TokenRing do

  def createProcess(0, counter, m) do
      
    receive do
      :token -> IO.puts("Process[0] (#{inspect(self())}) received token.")
      
      # Increment the counter when receiving :token
      new_counter = counter + 1
      #IO.puts("Process[0] (#{inspect(self())}) counter incremented to: #{new_counter}")
      IO.puts("Process[0] (#{inspect(self())}) got: #{new_counter} tokens.")
      
      # Check if we got all the tokens
      if new_counter == m do
      	IO.puts("Process[0] (#{inspect(self())}) ➡️ Got all the tokens and can shutdown gracefully. ✔️")
      	
      	# Write logs
      	current_datetime = DateTime.utc_now()
      	timestamp = DateTime.to_string(current_datetime)
      	FileWriter.write_to_file("TokenRing.log", "#{timestamp}: Process[0] (#{inspect(self())}) got all the #{m} tokens and shut gracefully down. ✔️\n")
      	IO.puts "### Log file #{"TokenRing.log"} successfully written. 🚀 ###"
      	Process.exit(self(), :normal)
      end      
      
      # Call the loop function again with the updated counter value
      createProcess(0, new_counter, m)
    
    end
    
  end

  def createProcess(n, counter, m) do

    # Spawn next process in the ring (recursively)
    nextProcessID = spawn(fn -> createProcess(n - 1, counter, m) end)

    # Receive token and then send it further to the next process
    receive do
      :token -> IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) received token.")
      
      	      # Pass the token to the next process
	      # IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) passes token to next process[#{n-1}]")
	      send(nextProcessID, :token)
      
	      # Increment the counter when receiving :token
	      new_counter = counter + 1
	      # IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) counter incremented to: #{new_counter}")
	      IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) got: #{new_counter} tokens.")
	      
              # Check if we got all the tokens
              if new_counter == m do
            	
            	
              	# Write logs
              	current_datetime = DateTime.utc_now()
      		timestamp = DateTime.to_string(current_datetime)
      		FileWriter.write_to_file("TokenRing.log", "#{timestamp}: Process[#{n}] (#{inspect(self())}) got all the #{m} tokens and shut gracefully down. ✔️ Successor: #{to_string(n-1)}\n")
      		IO.puts("Process[#{to_string(n)}] (#{inspect(self())}) ➡️ Got all the tokens and can shutdown gracefully. ✔️")
      		
              	Process.exit(self(), :normal)
	      end
	      
	      # Call the loop function again with the updated counter value
	      createProcess(n, new_counter, m)

    end
  end
  
  def start(n,m) do
  	# spawn all the processes
	firstProcessID = spawn(fn -> TokenRing.createProcess(n, 0, m) end)         # second argument must be null, its the definition of the counter

	# send m times a token into the ring (begin with the first (known) process
	IO.puts "### Sending #{m} token(s) into the ring. 🚀 ###"

	Enum.each(1..m, fn(_x) ->
	  send(firstProcessID, :token)
	end)
	
  end

end



### Let the TokenRing initiate! ###

TokenRing.start(5,2)	# first variable defines number of processes to be created (from n ...0), second variable must be >0 (which makes somehow sense)


