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
![swap]()

In the start of the algorithm the pivot swaps its value with the first element of the array so that it can be stored inside the A[1], out of the way, and when, finally, the partitioning is done we assign the pivot to equal a position relative to i and j, since the two of them overlap, with which we perform a swap between the pivot and the A[1]. The logical proof behind the correct allocation of the pivot position goes as follows:

<pre>
We have these posible ways of arranging i and j depending on if they are on a square that is
bigger '■' or smaller 'o' than the pivot.

   i j      
   ↓ ↓
a. o ■ | Here i meets an element smaller than A[1] so it moves forward ending up in the 
         black square with j.
b. ■ o | Here i is stuck at a black square so now j has to move but it cannot. A swap takes 
         place ending up with posiblitiy number 1.
c. ■ ■ | Here i is stuck so j moves to i's position.
d. o o | Here i moves to j's position
</pre>

<pre>
All in all, the end state is described by:
1| o ■ ← (i,j)  | 
2| ? ■ ← (i,j) ■|
3| o o ← (i,j) ?|
p.s.: ? symbolizes an element that we dont know if it exists or not
</pre>

- In case 1 we assign pivot to the element before i,j and swap its value with A[1].
- In case 2 we assign pivot to the element before i,j and if (i,j)!= 2 then we also swap its value with A[1]. 
- In case 3 we assign pivot to (i,j).
- In the extreme cases where the array is smaller than 3 elements in size:
    - If they are 2 then i==j so we dont need to change any elements position
    - Having only one element leads to i>j so the while loop doesnt run and the pivot==k

<pre>
After this procedure the array should always look like:
              pivot
                ↓
o o o o o o o o ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ 
</pre>

Finding the k-th value occurs when our randomly assigned pointer overlaps with the position of the k-th value of the sorted array. The way we are able to tell if this criteria is met is by counting how many elements are bigger than and smaller than our pivot. In other words, the pivot gets assigned its absolute sorted position each time the program sorts the array into those two parts. If pivot==k we are done. 
![pivot==k]()

If we don't get lucky we rise our chances by reducing the array to either the first or the second part depending on if k is bigger than the number of the elements that are less than the pivot. If it is bigger then the search is continues on the second part of the array but if it is smaller it continues on the first part. This way we progressively shorten the part of the array that we work on and rise our chances of the pivot overlapping with k. 
![recursion]() 

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
