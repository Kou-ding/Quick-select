# Open the file in read mode
file_path = "list.txt"  # Replace with the path to your file
file = open(file_path, "r")

# Read each line from the file and print the numbers
for line in eachline(file)
    number = parse(Float64, line)  # Assuming the numbers are floating-point, change to parse(Int, line) if they are integers
    println(number)
end

# Close the file
close(file)