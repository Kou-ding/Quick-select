using MPI

# Initialize MPI
MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)

# Each process has its own value
local_value = rank + 1

# The root process (rank 0) will receive the final result
root = 0
global_sum = MPI.Allreduce(local_value, MPI.SUM, comm)

# Print the result on all processes
println("Process $rank: Global sum is $global_sum")

# Finalize MPI
MPI.Finalize()