using MPI

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

function count_elements(A, element)
    count = 0
    for i in A
        if i < element
            count += 1
        end
    end
    return count
end

function all_equal(A)
    return length(unique(A)) == 1
end

function find_kth_element(A, k)
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)

    # Divide the array into subarrays
    subArray = Array{typeof(A[1])}(undef, length(A) ÷ size)
    MPI.Scatter(A, subArray, 0, comm)

    # Select a random element from the original array
    random_element = A[rand(1:length(A))]

    # Count the number of elements that are less than the random element
    count = count_elements(subArray, random_element)

    # Gather the counts from all processes
    counts = Array{typeof(count)}(undef, size)
    MPI.Gather(count, counts, 0, comm)

    if rank == 0
        # Sum up the counts from all processes
        total_count = sum(counts)

        if total_count > k
            # The k-th element is in the subarray [1:count]
            kth_element = subArray[1:count]
        else
            # The k-th element is in the subarray [count+1:end]
            kth_element = subArray[count+1:end]
        end

        # Check if the subarray contains only equal elements
        if all_equal(kth_element)
            return kth_element
        else
            # Repeat the process with the new subarray
            return find_kth_element(kth_element, k)
        end
    end
end

# Test the algorithm
init_array()
k = 50
kth_element = find_kth_element(A, k)
println("The k-th element is: ", kth_element)