# Initialize the array A[]
function init_array()
    # Initialize array
    global A=zeros(Int64,0)

    # Open the file in read mode
    file_path = "list.txt" 
    file = open(file_path, "r")

    # Read each line from the file and push them into the array
    for line in eachline(file)
        number = parse(Int64, line)  # Assuming the numbers are floating-point, change to parse(Int, line) if they are integers
        push!(A,number)
    end
end

init_array()

println("Pick a number out of $(length(A)):")
k = parse(Int64, readline())

elapsed_time = @elapsed begin
    sorted_A=sort(A)
    println("The element number $k of the sorted array is: $(sorted_A[k])")
end
println("Elapsed time: ", elapsed_time)