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

A = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# The array that is going to hold the subarrays
subA = divide_array(A, size-1)

if rank == 0
    for i in 1:size-1
        MPI.Isend(subA[i], i, i*10, comm)
    end
else
    for i in 1:size-1
        subA[i] = zeros(Int, length(subA[i]))
        MPI.Irecv!(subA[i], 0, i*10, comm)
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