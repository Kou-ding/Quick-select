function create_list()
    file = nothing  # Initialize file outside the try block
    try
        file_path = "list.txt"  # Change this to your desired file path
        file = open(file_path, "w")

        for i in 1:20
            random_number = rand(1:100)
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