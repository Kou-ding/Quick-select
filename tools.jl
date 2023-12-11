# prints the array sorted
for n in eachindex(A)
    println("The Array A[]:",n)
end

# prints the array as it is
for (index,value) in enumerate(A)
    println("A[$index]: $value")
    println("--------")
end

# array generation
A=100*rand(Int64,100)
A=zeros(Int64,100)
for n in 1:100
    A[n]=2*n
end