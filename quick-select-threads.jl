using Base.Threads

# Initialize the array A[]
function init_array()
    # Initialize array
    global A = zeros(Int64, 0)

    # Open the file in read mode
    file_path = "list.txt"
    file = open(file_path, "r")

    # Read each line from the file and push them into the array
    for line in eachline(file)
        number = parse(Int64, line)
        push!(A, number)
    end
end

init_array()

println("Pick a number out of $(length(A)):")
k = parse(Int64, readline())

# Function to perform the sorting in parallel using threads
function parallel_sort(A)
    return @threads sort(A)
end

elapsed_time = @elapsed begin
    sorted_A = parallel_sort(A)
    println("The element number $k of the sorted array is: $(sorted_A[k])")
end
println("Elapsed time: ", elapsed_time)
