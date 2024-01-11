# This function swaps only the values of A at places i and j without interfering with i and j themselves
function swap_elements!(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
end

using MPI
MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

# Open the file in read mode
file_path = "list.txt"
file = nothing  # Define file outside the try block
num_lines=0
# Identify how many lines are in the txt file
try
    global file = open(file_path, "r")

    # Count the lines in the file
    global num_lines = countlines(file)

finally
    # Make sure to close the file when you're done with it
    close(file)
end
print("number of lines[$rank]: $num_lines\n")

MPI.Barrier(comm)

# Determine how many and which lines to read from the txt file
if rank in 1:size-1
    chunk_size = div(num_lines, size-1)
end
if rank in 1:size-2
    lines_to_read = (rank-1)*chunk_size+1:rank*chunk_size
end
if rank == size-1
    lines_to_read = (rank-1)*chunk_size+1:num_lines
end

MPI.Barrier(comm)

# Push elements from the txt to the subA[rank]
subA = Vector{Vector{Int}}(undef, size-1)
if rank in 1:size-1
    subA[rank]= zeros(Int64,0)
    try
        global file = open(file_path, "r")
    
        # Read only the specified lines
        for (i, line) in enumerate(eachline(file))
            if i in lines_to_read
                push!(subA[rank],parse(Int64, line))
            end
        end
        # Close the file
        close(file)
    catch error
        println("Error: $error")
    
    finally
        if file !== nothing
            close(file)
        end
    end
end

MPI.Barrier(comm)

# Prompt to find the value of the k-th element, considering the array is sorted
# send k to all other processes
kBuff=[0]
if rank==0
    println("Pick a number out of $(num_lines):")
    global kBuff = parse(Int64, readline())
    for i in 1:size-1
        MPI.Isend(kBuff, i, i, comm)
    end
else
    for i in 1:size-1
        MPI.Irecv!(kBuff, 0, i, comm)
    end
end

# kBuff is needed in the next iteration
MPI.Barrier(comm)

# Store k inside another variable because we are going to be making changes to it
# Start the timer
if rank==0
    start_time = time()
    searching = kBuff[1]
    result=0 
end

# Initialize the pivot, lessLen and winCondition1
pivot=zeros(Int,1)
lessLen = 0
winCondition1Buff=[2]
winCondition2Buff=[0]
winCondition2=0

# winCondition1: If there is only one element left in the subarrays
# winCondition2: If the elements equal to the pivot are equal to the total number of elements in the subarrays
while ((winCondition1Buff[1] != 1) && (winCondition2Buff[1]!=winCondition1Buff[1]))
    # Send a random pivot from each sub array to the root process
    if rank in 1:size-1 && subA[rank] != []
        global pivot = [rand(subA[rank])]
        MPI.Isend(pivot, 0, rank, comm)
    end

    # Set the pivot to a random element of A in process 0 and send it to all other processes
    if rank == 0
        for i in 1:size-1
            MPI.Irecv!(pivot, i, i, comm)
        end
        for i in 1:size-1
            MPI.Isend(pivot, i, i, comm)
        end
    else
        for i in 1:size-1
            MPI.Irecv!(pivot, 0, i, comm)
        end
    end

    # pivot is needed in the next iteration
    MPI.Barrier(comm)

    if rank in 1:size-1 && subA[rank] == []
        global lessLen = 0
    end
    
    # Wait for all processes to finish
    #################################MPI.Barrier(comm)

    global winCondition2=0
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
                    if (subA[rank][j]==pivot[1])
                        global winCondition2 = winCondition2 + 1
                    end
                    j -= 1
                end
                swap_elements!(subA[rank],i,j)
            end

            # Differentiate based on if the common index, i and j are on, is bigger or smaller than the pivot
            if (subA[rank][j]<pivot[1])
                pivot_position=j
            elseif (subA[rank][j]>=pivot[1])
                pivot_position=j-1
                if (subA[rank][j]==pivot[1])
                    global winCondition2 = winCondition2 + 1
                end
            end
        
            if (i==j)
                global lessLen = pivot_position
                break
            end
        end
    end

    total_equal_pivot=[MPI.Reduce(winCondition2, MPI.SUM, comm)]

    if rank==0
        global winCondition2Buff=total_equal_pivot
        for i in 1:size-1
            MPI.Isend(winCondition2Buff, i, i, comm)
        end
    else
        for i in 1:size-1
            MPI.Irecv!(winCondition2Buff, 0, i, comm)
        end
    end

    # Wait for all processes to finish
    MPI.Barrier(comm) # seems to be very important

    # Gather all the lessLen from each process and add them together
    # format: MPI.Reduce(variables from processes to work on, operation, comm)
    total_lessLen=MPI.Reduce(lessLen, MPI.SUM, comm)

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

    # total_lessLenBuff is needed in the next iteration
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
        # Wait for all processes to finish
        #####################MPI.Barrier(comm)

        if rank in 1:size-1 && subA[rank] != []
            if lessLen == length(subA[rank])
                subA[rank] = []
            elseif lessLen < length(subA[rank])
                subA[rank] = subA[rank][lessLen+1:end]
            end
        end
    end

    # Wait for all processes to finish
    MPI.Barrier(comm) #seems to be very important

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

    # Sync before the next iteration of the while loop
    MPI.Barrier(comm)
end

# Stop the timer and print the elapsed time
if rank==0
    end_time = time()
    elapsed_time = end_time - start_time
    print("\nElapsed time: $elapsed_time seconds\n")
    print("\nThe $searching-th element is:")
end
# Barrier so that the processes don't print at the same time
MPI.Barrier(comm)
# Win condition 1: If there is only one element left in the subarrays
if ((rank != 0) && (subA[rank] != []))
    print(" $(subA[rank][1])\n")
end

MPI.Finalize()