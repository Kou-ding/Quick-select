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

function QuickSortSeq(subArray)
    # Execute this loop forever until
    while (true)
        # Set i and j each iteration of the while loop
        i = 1
        j = length(subArray)
        # pivot = rand(1:length(subArray))
        seperator=subArray[pivot]

        # Divide the array into 2 sides
        while (i<j)
            while ((subArray[i]<seperator) && (i<j))
                i += 1
            end
            while ((subArray[j]>=seperator) && (i<j))
                j -= 1
            end
            swap_elements!(subArray,i,j)
        end

        # Differentiate based on if the common index, i and j are on, is bigger or smaller than the pivot
        if (subArray[j]<seperator)
            seperator_position=j+1
        elseif (subArray[j]>=seperator)
            seperator_position=j
        end
        
        if (i==j)
            # less_sub=seperator_position-1
            more_sub=length(subArray)-seperator_position
            MPI.Send(more_sub, 0, 0, comm)
            break
        end
    end
end

function find_kth_element(A, k)
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)

    # Calculate the size of each chunk and the remainder
    chunk_size = length(A) ÷ size
    remainder = length(A) % size

    # Prepare a buffer to receive the chunk
    subArray = Array{typeof(A[1])}(undef, chunk_size + (rank < remainder ? 1 : 0))

    # Scatter the array
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
using MPI

# This function swaps only the values of A at places i and j without interfering with i and j themselves
function swap_elements!(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
end

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

function QuickSortSeq()
    # Execute this loop forever until
    while (true)
        # Set i and j each iteration of the while loop
        i = 1
        j = length(sub_A)
        pivot = rand(1:length(sub_A))
        seperator=sub_A[pivot]

        # Divide the array into 2 sides
        while (i<j)
            while ((A[i]<seperator) && (i<j))
                i += 1
            end
            while ((A[j]>=seperator) && (i<j))
                j -= 1
            end
            swap_elements!(A,i,j)
        end

        # Differentiate based on if the common index, i and j are on, is bigger or smaller than the pivot
        if (A[j]<seperator)
            seperator_position=j+1
        elseif (A[j]>=seperator)
            seperator_position=j
        end
        
        if (i==j)
            # less_sub=seperator_position-1
            more_sub=length(sub_A)-seperator_position
            MPI.Send(more_sub, 0, 0, comm)
            break
        end
    end
end

function k_elements(A)
    count_eq=0
    for index in eachindex(A)
        if A[1]==A[index]
            count_eq+=1
        end
    end
    return count_eq == length(A)-1
end

# Populating an array with the list's values
init_array()

# Prompt to find the value of the k-th element, considering the array is sorted
println("Pick a number out of $(length(A)):")
k = parse(Int64, readline())

# Store k inside another variable because we are going to be making changes to it
searching = k 

MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

# Assuming the array A is available on the root process
if rank == 0
    increment=div(length(A), size)+1
    start_position=1
    for i in 1:size-1
        increment=div(length(A), (size-1))+1
        end_position=position+increment-1
        MPI.Send(A[start_position:end_position], i, 0, comm)
        start_position=i*increment
    end
else
    for i in 1:size-1
        sub_A[i] = MPI.Recv(i, 0, comm)
        println("Process $rank received: $(sub_A[i])")
    end
end

if rank == 0
    if (length(A)==1 || k_elements(A))
    println("The element number $searching of the sorted array is: $(A[1])")
    else
        QuickSortSeq()
    end
end 

if rank == 0
    # Root process code...
else
    for i in 1:size-1
        sub_A[i] = MPI.Recv(i, 0, comm)
        println("Process $rank received: $(sub_A[i])")
    end
    QuickSortSeq()
end
MPI.Barrier(comm)
MPI.Finalize()





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

# This function swaps only the values of A at places i and j without interfering with i and j themselves
function swap_elements!(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
end

function QuickSortSeq(subArray,pivot_buffer,comm)
    # Execute this loop forever until
    while (true)
        # Set i and j each iteration of the while loop
        i = 1
        j = length(subArray)
        pivot = pivot_buffer[1]

        # Divide the array into 2 sides
        while (i<j)
            while ((subArray[i]<pivot) && (i<j))
                i += 1
            end
            while ((subArray[j]>=pivot) && (i<j))
                j -= 1
            end
            swap_elements!(subArray,i,j)
        end

        # Differentiate based on if the common index, i and j are on, is bigger or smaller than the pivot
        if (subArray[j]<pivot)
            pivot_position=j+1
        elseif (subArray[j]>=pivot)
            pivot_position=j
        end
        
        if (i==j)
            lessArray = subArray[1:pivot_position-1]
            moreArray = subArray[pivot_position:length(subArray)]
            return lessArray, moreArray
        end
    end
end

init_array()

# Prompt to find the value of the k-th element, considering the array is sorted
println("Pick a number out of $(length(A)):")
k = parse(Int64, readline())

# Store k inside another variable because we are going to be making changes to it
searching = k 

MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

# Calculate the size of each chunk and the remainder
chunk_size = length(A) ÷ size
remainder = length(A) % size

# Prepare a buffer to receive the chunk
subArray = Array{typeof(A[1])}(undef, chunk_size + (rank < remainder ? 1 : 0))

# Scatter the array
MPI.Scatter(A, subArray, 0, comm)

# Generate the pivot on the root process
if rank == 0
    pivot_pos = rand(1:length(A))
    pivot = A[pivot_pos]
end

# Prepare a buffer to receive the pivot
pivot_buffer = Array{typeof(pivot)}(undef, 1)

# If rank is 0, put the pivot in the buffer
if rank == 0
    pivot_buffer[1] = pivot
end

# Broadcast the pivot
MPI.Bcast!(pivot_buffer, 0, comm)

MPI.Barrier(comm)

if rank!= 0
    lessArray, moreArray = QuickSortSeq(subArray,pivot_buffer[1],comm)
else
    lessArray = Array{typeof(A[1])}(undef, 0)
    moreArray = Array{typeof(A[1])}(undef, 0)
end
MPI.Barrier(comm)

# Prepare a buffer on the root process to receive the gathered data
if rank == 0
    gather_buffer_less = Array{typeof(A[1])}(undef, length(A))
    gather_buffer_more = Array{typeof(A[1])}(undef, length(A))
else
    gather_buffer_less = nothing
    gather_buffer_more = nothing
end

# Gather the data
MPI.Gatherv!(lessArray, gather_buffer_less, 0, comm)
MPI.Gatherv!(moreArray, gather_buffer_more, 0, comm)

MPI.Barrier(comm)

# If rank is 0, print the gathered data
if rank == 0
    println("lessArray: ", gather_buffer_less)
    println("moreArray: ", gather_buffer_more)
end


MPI.Finalize()
=========================================================
test.jl
while(true)
    # This function swaps only the values of A at places i and j without interfering with i and j themselves
    function swap_elements!(arr, i, j)
        arr[i], arr[j] = arr[j], arr[i]
    end

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

    # Creating a list and immidiately populating an array with its values
    init_array()

    # Prompt to find the value of the k-th element, considering the array is sorted
    println("Pick a number out of $(length(A)):")
    k = parse(Int64, readline())

    # Find the k-th element for sure by actually sorting the array 
    sorted_A=sort(A)
    correct_result=sorted_A[k]

    #######################################
    println("Sorted A:")
    for (index,value) in enumerate(sorted_A)
        println("A[$index]: $value")
    end
    #######################################

    # Store k inside another variable because we are going to be making changes to it
    searching = k 

    # calculate the elapsed time 
    elapsed_time = @elapsed begin
        # Execute this loop forever until k==pivot where the program exits gracefully
        while(true)
            # Set i and j each iteration of the while loop
            i = 2
            j = length(A)
            pivot = rand(1:length(A))

            ########################
            println("pivot: $pivot")
            println("A[pivot]: $(A[pivot])")
            ########################

            # If pivot is already the first element no need to swap
            if(1!=pivot) 
                swap_elements!(A,1,pivot) # position 1 stores the value of the pivot
            end

            # Divide the array into 2 sides
            while(i<j)
                while ((A[i]<A[1]) && (i<j))
                    i += 1
                end
                while ((A[j]>=A[1]) && (i<j))
                    j -= 1
                end
                swap_elements!(A,i,j)
            end

            
            #############################
            for (index,value) in enumerate(A)
                println("A[$index]: $value")
            end
            println("--------")
            #############################


            # Differentiate based on if the common index, i and j are on, is bigger or smaller than the pivot
            if((A[j]<A[1]))
                pivot=j
                swap_elements!(A,pivot,1)
            elseif(A[j]>=A[1])
                if(j==1)
                    pivot=j
                elseif(j>=2)
                    pivot=j-1
                    swap_elements!(A,pivot,1)
                end
            end

            ########################
            println("\ni,j: $i | $j")
            println("\nafter loop pivot: $pivot")
            println("after loop A[pivot]: $(A[pivot])\n")
            ########################

            # Dealing with the different possibilities of k's relative position to j
            if(pivot==k)
                println("The correct result is: $correct_result")
                global result=A[pivot]
                println("The element number $searching of the sorted array is: $(A[pivot])")
                break
            end
            if(pivot>k)
                global A = A[1:(pivot-1)] #shrink the array
            end
            if(pivot<k)
                global A = A[(pivot+1):end] #shrink the array
                k = k-pivot #redefine the position of the k-th element in the emerging
            end
        end
    end
    println("Elapsed time: ", elapsed_time)

    if(result!=correct_result)
        break
    elseif(result==correct_result)
        println("correct")
    end
end