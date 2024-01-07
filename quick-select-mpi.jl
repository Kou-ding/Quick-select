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

# Initialize the array
init_array()

# The array that is going to hold the subarrays of A
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

for rank in 1:size-1
    while (true)
        # Set i and j each iteration of the while loop
        i = 1
        j = length(subA[rank])
        pivot = 7

        # Divide the array into 2 sides
        while (i<j)
            while ((subA[rank][i]<pivot) && (i<j))
                i += 1
            end
            while ((subA[rank][j]>=pivot) && (i<j))
                j -= 1
            end
            swap_elements!(subA[rank],i,j)
        end

        # Differentiate based on if the common index, i and j are on, is bigger or smaller than the pivot
        if (subA[rank][j]<pivot)
            pivot_position=j+1
        elseif (subA[rank][j]>=pivot)
            pivot_position=j
        end
        
        if (i==j)
            global lessLen = pivot_position - 1
            moreLen = length(subA[rank]) - lessLen
            break
        end
    end
end

##########################
# Wait for all processes to finish
MPI.Barrier(comm)

totalLessLen = [0]
# Reduce all lessLen values to totalLessLen in process 0
MPI.Reduce(lessLen, totalLessLen, MPI.SUM, 0, comm)

# In process 0, print the total lessLen
if rank == 0
    println("Total lessLen: $(totalLessLen[1])")
end
##########################

for i in 1:size-1
    if rank == i
        print("Process $rank received $(subA[i]) from process 0\n")
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)


MPI.Finalize()