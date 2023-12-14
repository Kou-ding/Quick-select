# prints the array sorted
for n in eachindex(A)
    println("The Array A[]:",n)
end

# prints the array as it is
println("--------")
for (index,value) in enumerate(A)
    println("A[$index]: $value")
end

# array generation
A=100*rand(Int64,100)
A=zeros(Int64,100)
for n in 1:100
    A[n]=2*n
end

########################
println("\ni,j: $i | $j")
println("\nafter loop pivot: $pivot")
println("after loop A[pivot]: $(A[pivot])\n")
########################

#############################
for (index,value) in enumerate(A)
    println("A[$index]: $value")
end
println("--------")
#############################

########################
println("pivot: $pivot")
println("A[pivot]: $(A[pivot])")
########################

#######################################
println("Sorted A:")
for (index,value) in enumerate(sorted_A)
    println("A[$index]: $value")
end
#######################################