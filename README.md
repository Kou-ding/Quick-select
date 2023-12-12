# Quick-select-Assignment

## Homework 2
In this assignment we have to find the k-th value of an array, considering the array to be sorted. We will be using MPI to coordinate this search and apply this algorithm to datasets that cannot fit into one machine since when the data can fit into one computational machine the program should always run faster when executed locally.


## Quick select easy
- quick-select-easy.jl

Julia sorts the array and then returns the k-th element by printing the k-th element of the sorted array.
```julia
sorted_A=sort(A)
println("The element number $k of the sorted array is: $(sorted_A[k])")
```

## Quick select sequential
- quick-select-seq.jl

This algorithm revolves around creating a random `pivot` point somewhere inside the array and using it to seperate the array into two parts. The first part of the array contains only elements that are smaller than the pivot point and the second part contains elements equal or bigger than the pivot point. 
![two parts](/media/quick-select.png)

After having two pointers traverse the array, one from the start and one from the end, whenever they each come in contact with an element that should be on the opposite side the swap values and continue doing that until they have met each other. 
![swap](/media/quick-select.png)

Finding the k-th value occurs when our randomly assigned pointer overlaps with the position of the k-th value of the sorted array. The way we are able to tell if this criteria is met is by counting how many elements are bigger than and smaller than our pivot. In other words, the pivot gets assigned its absolute sorted position each time the program sorts the array into those two parts. If pivot==k we are done. 
![pivot==k](/media/quick-select.png)

If we don't get lucky we rise our chances by reducing the array to either the first or the second part depending on if k is bigger than the number of the elements that are less than the pivot. If it is bigger then the search is continues on the second part of the array but if it is smaller it continues on the first part. This way we progressively shorten the part of the array that we work on and rise our chances of the pivot overlapping with k. 
![recursion](/media/quick-select.png) 

## Quick select mpi


## Times
Execution times mean, Array:
|qs-easy|qs-seq|qs-mpi| 
|-------|------|------|
||||
||||
||||
||||
||||
|Mean score|Mean score|Mean score|
||||

## Tutorial
In order for the program (quick-select-mpi.jl) to run the MPI julia library needs to be imported and mpiexecjl needs to be installed. After launching the julia terminal type:
> import Pkg; Pkg.add("MPI")
> using MPI; MPI.install_mpiexecjl()

External sources
----------------
- Julia tutorials: https://julialang.org/learning/tutorials/
- Multi-Threading: https://docs.julialang.org/en/v1/manual/multi-threading/
- Introduction to Julia: https://www.youtube.com/watch?v=4igzy3bGVkQ&list=PLP8iPy9hna6SCcFv3FvY_qjAmtTsNYHQE
- 
