using HashCode2014
using HashCode2014Solution

city = read_city()

@time solution = fast_random_walk_repeated(city; trials=10)

@test is_feasible(solution, city)
distance = total_distance(solution, city)

# write_solution(
#     solution,
#     joinpath(@__DIR__, "..", "solution", "solution_$distance.txt"),
# )

# solution_backup = read_solution(first(readdir(joinpath(@__DIR__, "..", "solution"); join=true)))

# @assert is_feasible(solution_backup, city)
# total_distance(solution_backup, city)
