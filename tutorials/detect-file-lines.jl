# Open the file in read mode
file_path = "list.txt"
file = nothing  # Define file outside the try block
try
    global file = open(file_path, "r")

    # Count the lines in the file
    num_lines = countlines(file)

    println("Number of lines in $file_path: $num_lines")

finally
    # Make sure to close the file when you're done with it
    close(file)
end
