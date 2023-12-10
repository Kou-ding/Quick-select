# Quick-select
In order for the program to run the MPI julia library needs to be imported and mpiexecjl needs to be installed. After launching the julia terminal type:
> import Pkg; Pkg.add("MPI")
> using MPI; MPI.install_mpiexecjl()