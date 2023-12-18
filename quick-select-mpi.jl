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

MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
comm_size = MPI.Comm_size(comm)

root = 0

if rank == root

    init_array()
    
    # Calculate the size of each chunk and the remainder
    chunk_size = length(A) ÷ size
    remainder = length(A) % size

    # Prepare a buffer to receive the chunk
    subArray = Array{typeof(A[1])}(undef, chunk_size + (rank < remainder ? 1 : 0))

    # Scatter the array
    MPI.Scatter(A, subArray, 0, comm)
    MPI.Barrier(comm)

    # Prepare a buffer to broadcast the pivot
    pivot_pos = rand(1:length(A))
    pivot = A[pivot_pos]
    pivot_buffer = Array{typeof(pivot)}(undef, 1)
    pivot_buffer[1] = pivot
    
    # Broadcast the pivot
    MPI.Bcast!(pivot_buffer, 0, comm)
    MPI.Barrier(comm)
else
    # these variables can be set to `nothing` on non-root processes
    pivot_buffer = nothing
end

if rank == root
    println("Original matrix")
    println("================")
    @show A 
    println()
    println("Each rank")
    println("================")
end 
MPI.Barrier(comm)

local_A = MPI.Scatterv!(A, subArray, root, comm)

for i = 0:comm_size-1
    if rank == i
        @show rank local_A
    end
    MPI.Barrier(comm)
end

MPI.Gatherv!(local_A, output, root, comm)

if rank == root
    println()
    println("Final matrix")
    println("================")
    @show output
end 