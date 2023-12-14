# Initialize the array A[]
function create_list()
    file = nothing  # Initialize file outside the try block
    println("How many elements do you want the array to be?")
    length_A = parse(Int64, readline())
    print("\nNice!\nNow select the range of the values.\nLower limit:")
    lo_lim = parse(Int64, readline())
    print("\nUpper limit:")
    up_lim = parse(Int64, readline())
    try
        file_path = "list.txt"  # Change this to your desired file path
        file = open(file_path, "w")

        for i in 1:length_A
            random_number = rand(lo_lim:up_lim)
            println(file, random_number)
        end

        println("Random numbers have been written to $file_path.")

    catch e
        println("Error: $e")
    finally
        close(file)
    end
end

create_list()