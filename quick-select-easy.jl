A=rand(1:1000,500)
println("Pick a number out of $(length(A)):")
k = parse(Int64, readline())
elapsed_time = @elapsed begin
    sorted_A=sort(A)
    println("The element number $k of the sorted array is: $(sorted_A[k])")
end
println("Elapsed time: ", elapsed_time)