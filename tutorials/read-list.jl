# Initialize array
A= zeros(Float64,0)
list_len=0

# Open the file in read mode
file_path = "list.txt" 
file = open(file_path, "r")
# Read each line from the file and push them into the array
for line in eachline(file)
    number = parse(Float64, line)  # Assuming the numbers are floating-point, change to parse(Int, line) if they are integers
    push!(A,number)
    global list_len+=1
end
# Close the file

close(file)
for n in 1:list_len
    println(A[n])
end