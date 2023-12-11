# This function swaps only the values of A at places i and j without interfering with i and j themselves
function swap_elements!(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
end

# Initialize the array A[]
A=rand(1:1000,5000)

# Prompt to find the value of the k-th element, considering the array is sorted
println("Pick a number out of $(length(A)):")
k = parse(Int64, readline())
searching = k # Store k inside another variable because we are going to be making changes to it

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

        # Differentiate based on if the common index i and j are on, is bigger or smaller than the pivot
        if((A[j]<A[1]))
            pivot=j
            swap_elements!(A,1,j)
        end
        if(A[j]>=A[1])
            if(j==2)
                pivot=j-1
            end
            if(j>2)
                pivot=j-1
                swap_elements!(A,pivot,1)
            end
        end

        # Dealing with the different possibilities of k's relative position to j
        if(pivot>k)
            global A = A[1:(pivot)] #shrink the array
        end
        if(pivot<k)
            global A = A[(pivot+1):end] #shrink the array
            global k = k-pivot #redefine the position of the emerging we are trying to find
        end
        if(pivot==k)
            println("The element number $searching of the sorted array is: $(A[k])")
            break
        end
    end
end
println("Elapsed time: ", elapsed_time)