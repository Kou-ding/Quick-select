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