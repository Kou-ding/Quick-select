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

# Populating an array with the list's values
init_array()

# Prompt to find the value of the k-th element, considering the array is sorted
println("Pick a number out of $(length(A)):")
k = parse(Int64, readline())

# Find the k-th element for sure by actually sorting the array 
sorted_A=sort(A)
println("The correct element number $k of the sorted array is: $(sorted_A[k])")

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

        # Dealing with the different possibilities of k's relative position to j
        if(pivot==k)
            println("The element number $searching of the sorted array is: $(A[pivot])")
            break
        end
        if(pivot>k)
            global A = A[1:(pivot-1)] #shrink the array
        end
        if(pivot<k)
            global A = A[(pivot+1):end] #shrink the array
            global k = k-pivot #redefine the position of the k-th element in the emerging
        end
    end
end
println("Elapsed time: ", elapsed_time)