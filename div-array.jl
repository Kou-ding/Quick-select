using MPI
MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

subA = zeros(Int, size+1)
if rank == 0
    # Initialize the array
    A = [1,2,3,4,5,6,7,8,9]
    
    for i in 1:size-1
        global subA = A[1:i+1] 
        MPI.Isend(subA, i, i, comm)
    end
else
    for rank in 1:size-1
        MPI.Irecv!(subA, 0, rank, comm)
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)

# Print the subarrays

print("Process $rank received $(subA) from process 0\n")


# Wait for all processes to finish
MPI.Barrier(comm)

MPI.Finalize()