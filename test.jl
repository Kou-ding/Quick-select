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

# This function swaps only the values of A at places i and j without interfering with i and j themselves
function swap_elements!(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
end

# This function divides an array into n subarrays
function divide_array(A, n)
    subA = Vector{Vector{Int}}(undef, n)
    chunk_size = div(length(A), n)
    
    for i in 1:n-1
        subA[i] = A[(i-1)*chunk_size+1 : i*chunk_size]
    end
    
    subA[n] = A[(n-1)*chunk_size+1 : end]
    
    return subA
end

using MPI
MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

# Define subA at a higher scope
subA = [zeros(Int, 4) for _ in 1:size-1]

if rank == 0
    # Initialize the array
    init_array()
    # The array that is going to hold the subarrays of A
    global subA = divide_array(A, size-1)
    for i in 1:size-1
        MPI.Isend(subA[i], i, i, comm)
    end
else
    if rank in 1:size-1
        MPI.Irecv!(subA[rank], 0, rank, comm)
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)

if rank==0
    # Prompt to find the value of the k-th element, considering the array is sorted
    println("Pick a number out of $(length(A)):")
    k = parse(Int64, readline())

    # Store k inside another variable because we are going to be making changes to it
    searching = k 
end

# Initialize the pivot and lessLen
pivot=zeros(Int,1)
lessLen = 0

# Set the pivot to a random element of A in process 0 and send it to all other processes
if rank == 0
    #global pivot = [rand(A)]
    global pivot = 10
    for i in 1:size-1
        MPI.Isend(pivot, i, i, comm)
    end
    println("Root pivot: $(pivot[1])")
else
    for i in 1:size-1
        MPI.Irecv!(pivot, 0, i, comm)
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)

# Apply the sequential quick-select algorithm to each subarray
if rank in 1:size-1
    while (true)
        # Set i and j each iteration of the while loop
        i = 1
        j = length(subA[rank])

        # Divide the array into 2 sides
        while (i<j)
            while ((subA[rank][i]<pivot[1]) && (i<j))
                i += 1
            end
            while ((subA[rank][j]>=pivot[1]) && (i<j))
                j -= 1
            end
            swap_elements!(subA[rank],i,j)
        end

        # Differentiate based on if the common index, i and j are on, is bigger or smaller than the pivot
        if (subA[rank][j]<pivot[1])
            pivot_position=j
        elseif (subA[rank][j]>=pivot[1])
            pivot_position=j-1
        end
    
        if (i==j)
            global lessLen = pivot_position
            print("lessLen of process $rank: $(lessLen)\n")
            moreLen = length(subA[rank]) - lessLen
            break
        end
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)

# Print the subarrays
if rank in 1:size-1
    print("Process $rank received $(subA[rank]) from process 0\n")
end

# Gather all the lessLen from each process and add them together
# format: MPI.Reduce(variables from processes to work on, operation, comm)
total_lessLen=MPI.Reduce(lessLen, MPI.SUM, comm)

# Now, total_lessLen in the root process (rank 0) holds the sum of all lessLen
if rank == 0
    println("Total lessLen: $total_lessLen")
end

# Wait for all processes to finish
MPI.Barrier(comm)

MPI.Finalize()