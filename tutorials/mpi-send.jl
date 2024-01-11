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

# Initialize length_array and subA at a higher scope
length_array=zeros(Int,1)
subA = Vector{Vector{Int}}(undef, size-1)

# Initialize the array
if rank == 0
    A = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
end

# Send the length of A to all other processes
if rank == 0
    length_array = length(A)
    for i in 1:size-1
        MPI.Isend(length_array, i, i, comm)
    end
else
    if rank in 1:size-1
        MPI.Irecv!(length_array, 0, rank, comm)
    end
end

# length_array is needed in the next iteration
MPI.Barrier(comm)

# Divide the array into subarrays and send them to all other processes
if rank == 0
    # The array that is going to hold the subarrays of A
    subA = divide_array(A, size-1)
    for i in 1:size-1
        MPI.Isend(subA[i], i, i, comm)
    end
else
    if rank in 1:size-1
        A=zeros(Int,length_array[1])
        chunk_size = div(length_array[1], size-1)
        # Initialize the subarray
        if rank in 1:size-2
            subA[rank] = A[(rank-1)*chunk_size+1 : rank*chunk_size]
        end
        if rank == size-1
            subA[rank] = A[(rank-1)*chunk_size+1 : end]
        end
        MPI.Irecv!(subA[rank], 0, rank, comm)
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)

for i in 1:size-1
    if rank == i
        print("Process $rank received $(subA[i]) from process 0\n")
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)

MPI.Finalize()