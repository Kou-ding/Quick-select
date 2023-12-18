# Quick-select-Assignment

## Homework 2
In this assignment we have to find the k-th value of an unsorted array, when considering the array to be sorted. We will be using MPI to coordinate this search and apply this algorithm to datasets that cannot fit into one machine since when the data can fit into one computational machine the program should always run faster when executed locally.


## Quick select easy
- quick-select-easy.jl

Julia sorts the array and then returns the k-th element by printing the k-th element of the sorted array.

```julia
sorted_A=sort(A)
println("The element number $k of the sorted array is: $(sorted_A[k])")
```


## Quick select sequential
- quick-select-seq.jl

This algorithm revolves around creating a random `pivot` point somewhere inside the array and using it to seperate the array into two parts. The first part of the array contains only elements that are smaller than the pivot point *symblized with 'o'* and the second part contains elements equal or bigger than the pivot point *symblized with '■'*. 
![two parts](/media/quick-select.png)

After having two pointers traverse the array, one from the start and one from the end, whenever they each come in contact with an element that should be on the opposite side the swap values and continue doing that until they have met each other. 
<pre>
Both i and j have encountered an element on the wrong side.

      i                         j
      ↓                         ↓
o o o ■ o ■ ■ o o o ■ o o ■ ■ ■ o ■ ■ ■ ■ ■ 

So, they swap

      i                         j
      ↓                         ↓
o o o o o ■ ■ o o o ■ o o ■ ■ ■ ■ ■ ■ ■ ■ ■ 

and continue parsing the array from both sides.
</pre>

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
2| ? ■ ← (i,j) ■| if '?' exists it is 'o'
3| o o ← (i,j) ?| if '?' exists it is '■'
p.s.: '?' symbolizes an element that we dont know if it exists or not
</pre>

- In case 1 we assign pivot to the element before i,j and swap its value with `A[1]`.
- In case 2 we assign pivot to the element before i,j and if `(i,j)!= 2` then we also swap its value with `A[1]`. 
- In case 3 we assign pivot to (i,j).
- In the extreme cases where the array is smaller than 3 elements in size:
    - If they are 2 then `i==j` so we dont need to change any elements position
    - Having only one element leads to `i>j` so the while loop doesnt run and the `pivot==k`

<pre>
After this procedure the array should always look like:
              pivot
                ↓
o o o o o o o o ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ 
</pre>

Finding the k-th value occurs when our randomly assigned pointer overlaps with the position of the k-th value of the sorted array. The way we are able to tell if this criteria is met is by counting how many elements are bigger than and smaller than our pivot. In other words, the pivot gets assigned its absolute sorted position (meaning: correct position in a sorted array) each time the program sorts the array into those two parts. If pivot==k we are done. 
If we don't get lucky we rise our chances by reducing the array to either the first or the second part depending on if k is bigger than the number of the elements that are less than the pivot. If it is bigger then the search is continues on the second part of the array but if it is smaller it continues on the first part. This way we progressively shorten the part of the array that we work on and rise our chances of the pivot overlapping with k. 

<pre>
Lets say it is bigger than the pivot:

               pivot      (keep this)
                ↓              ↓ 
o o o o o o o o ■ | ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ |

Lets say now it's smaller than the new pivot:

                     (keep this)  new pivot
                          ↓           ↓
                  | o o o o o o o o | ■ ■ ■ ■ ■

Now bigger again:
               new pivot deluxe
                      ↓
                  o o ■ | ■ ■ ■ ■ ■ |

Now bigger again:
                     new pivot deluxe plus
                              ↓
                        o o o ■ | ■ |  

Now bigger again:
                            Value found!
                                  ↓
                                  ■

This has been a quick visual representation of the program's steps.
</pre>

## Quick select mpi
In this algorithm we have to split the whole array into **n** number of sub arrays and scatter them, one sub array to each proccess. Then we will have to tweak the way we determine when we have reached the k-th element. This way involves seperating the subarrays again into two parts, one >= than the pivot and one < than the pivot but here we broadcast a pivot sampled from the whole array that all of the subarrays are going to compare against. Because the pivot might not appear in some sub arrays we don't pick a pivot element in the start of the quick select process to put aside and remember for later but we start from the start and end of the subarray performing the same swapping algorithm as in the sequential one.  

## Times & Time Complexity
Execution times mean, Array:
|qs-easy|qs-seq|qs-mpi|qs-threads|
|-------|------|------|----------|
|||||
|||||
|||||
|||||
|||||
|Mean score|Mean score|Mean score|Mean score|
|||||

#### Time complexity
- quick-select-easy.jl
      - 

- quick-select-seq.jl
      - 

- quick-select-mpi.jl
      - 

- quick-select-threads.jl
      - 


## Tutorial
First things first, you have to create a list (txt file) by executing:

```bash
julia create_list.jl
# this is going to prompt you to configure the number 
# and range of the array's randomly generated elements 
``` 

After this you run the sequential code by:

```bash
julia quick-select-seq.jl
# you have to enter k, to get the k-th value
``` 
In order for the program (quick-select-mpi.jl) to run the MPI julia library needs to be imported and mpiexecjl needs to be installed. After launching the julia terminal type:

```julia
import Pkg; Pkg.add("MPI")
using MPI; MPI.install_mpiexecjl()
```

Then exit the julia terminal by typing ctr-D. Now, a good practice is to add mpiexecjl to the system path but you can also, alternatively, type the whole address. Run the following command inside the repository's folder:

```bash
# if mpiexecjl is NOT in the path
/home/user/julia/julia-1.9.4/bin/mpiexecjl -n 2 julia quick-select-mpi.jl
# if mpiexecjl is in the path
mpiexecjl -n 2 julia quick-select-mpi.jl

```
The number that comes after -n is the number of ranks and you are able to configure it freely when calling the program.

>if at any time you have any questions feel free to message me **Ü**


External sources
----------------
- Julia tutorials: https://julialang.org/learning/tutorials/
- Multi-Threading: https://docs.julialang.org/en/v1/manual/multi-threading/
- Introduction to Julia: https://www.youtube.com/watch?v=4igzy3bGVkQ&list=PLP8iPy9hna6SCcFv3FvY_qjAmtTsNYHQE
- 
