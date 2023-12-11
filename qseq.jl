function swap_elements!(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
end

#A=100*rand(Float64,100)
A=zeros(Int64,100)
for n in 1:100
    A[n]=2*n
end
#=
for n in 1:length(A)
    println(A[n])
end
=#
pivot=rand(1:length(A))
println(A[pivot])
A=A[80:99]
i=A[1]
j=A[end]
println(i) 
println(j) 
println(A[1])
println(A[2])
swap_elements!(A,1,2)
println(A[1])
println(A[2])


#=
i=1
j=length(A)
while ((A[i]<A[pivot]) && (i<j))
    i+=1
end
while ((A[j]>=A[pivot]) && (i<j))
    j-=1
end
=#