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

# Initialize length_array and subA at a higher scope
length_array=zeros(Int,1)
subA = Vector{Vector{Int}}(undef, size-1)

# Initialize the array
if rank == 0
    init_array()
end

# Wait for all processes to finish
MPI.Barrier(comm)

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

# Wait for all processes to finish
MPI.Barrier(comm)

# Divide the array into subarrays and send them to all other processes
if rank == 0
    # The array that is going to hold the subarrays of A
    subA = divide_array(A, size-1) #might need to type global in the start
    for i in 1:size-1
        MPI.Isend(subA[i], i, i, comm)
    end
else
    if rank in 1:size-1
        A=zeros(Int,length_array[1])
        chunk_size = div(length_array[1], size-1)
        # Initialize the subarray
        subA[rank] = A[(rank-1)*chunk_size+1 : rank*chunk_size]
        MPI.Irecv!(subA[rank], 0, rank, comm)
    end
end

# Wait for all processes to finish
MPI.Barrier(comm)

# Prompt to find the value of the k-th element, considering the array is sorted
# send k to all other processes
kBuff=[0]
if rank==0
    println("Pick a number out of $(length(A)):")
    global kBuff = parse(Int64, readline())
    for i in 1:size-1
        MPI.Isend(kBuff, i, i, comm)
    end
else
    for i in 1:size-1
        MPI.Irecv!(kBuff, 0, i, comm)
    end
end

# Store k inside another variable because we are going to be making changes to it
if rank==0
    searching = kBuff[1]
    result=0 
end

# Initialize the pivot, lessLen and winCondition1
pivot=zeros(Int,1)
lessLen = 0
winCondition1Buff=[2]

while (winCondition1Buff[1] != 1)
    # Set the pivot to a random element of A in process 0 and send it to all other processes
    if rank == 0
        global pivot = [rand(A)]
        #global pivot = 7
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
    if rank in 1:size-1 && subA[rank] == []
        global lessLen = 0
    end
    # Wait for all processes to finish
    MPI.Barrier(comm)
    # Apply the sequential quick-select algorithm to each subarray
    if rank in 1:size-1 && subA[rank] != []
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

    # Send the total_lessLen to all other processes
    total_lessLenBuff=[0]
    if rank==0
        global total_lessLenBuff=total_lessLen
        for i in 1:size-1
            MPI.Isend(total_lessLenBuff, i, i, comm)
        end
    else
        for i in 1:size-1
            MPI.Irecv!(total_lessLenBuff, 0, i, comm)
        end
    end

    # Wait for all processes to finish
    MPI.Barrier(comm)

    if rank in 0:size-1
        print("k $rank: $(kBuff)\n")
        print("total lessLen $rank: $(total_lessLenBuff)\n")
    end
    # Wait for all processes to finish
    MPI.Barrier(comm)

    # Reduce the subarrays to the ones that are going to be used in the next iteration
    if total_lessLenBuff >= kBuff 
        if rank in 1:size-1 && subA[rank] != []
            if lessLen == 0
                subA[rank] = []
            elseif lessLen > 0 
                subA[rank] = subA[rank][1:lessLen]
            end
            
        end
    end
    if total_lessLenBuff < kBuff 
        if rank==0
            global kBuff = kBuff - total_lessLenBuff
            for i in 1:size-1
                MPI.Isend(kBuff, i, i, comm)
            end
        else
            for i in 1:size-1
                MPI.Irecv!(kBuff, 0, i, comm)
            end
        end
        MPI.Barrier(comm)
        if rank in 1:size-1 && subA[rank] != []
            if lessLen == length(subA[rank])
                subA[rank] = []
            elseif lessLen < length(subA[rank])
                subA[rank] = subA[rank][lessLen+1:end]
            end
        end
    end

    # Wait for all processes to finish
    MPI.Barrier(comm)
    
    # Print the subarrays
    if rank in 1:size-1
        print("Process $rank received $(subA[rank]) from process 0\n")
        print("kBuff $rank is $(kBuff)\n")
    end
    
    # Wait for all processes to finish
    MPI.Barrier(comm)

    soleElementCheck=0
    if rank in 1:size-1
        soleElementCheck=length(subA[rank])
    end
    winCondition1=MPI.Reduce(soleElementCheck, MPI.SUM, comm)

    winCondition1Buff=[0]
    if rank==0
        global winCondition1Buff=winCondition1
        for i in 1:size-1
            MPI.Isend(winCondition1Buff, i, i, comm)
        end
    else
        for i in 1:size-1
            MPI.Irecv!(winCondition1Buff, 0, i, comm)
        end
    end

    # Wait for all processes to finish
    MPI.Barrier(comm)
    
    if rank in 0:size-1
        print("winCondition1Buff $rank is $(winCondition1Buff)\n")
    end

    # Wait for all processes to finish
    MPI.Barrier(comm)
end

if rank==0
    print("\nThe $searching-th element is:")
end
# Wait for all processes to finish
MPI.Barrier(comm)

# Win condition 1: If there is only one element left in the subarrays
if ((rank != 0) && (subA[rank] != []))
    print(" $(subA[rank][1])\n")
end

# Wait for all processes to finish
MPI.Barrier(comm)

MPI.Finalize()