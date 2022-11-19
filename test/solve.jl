using HashCode2014
using HashCode2014Solution
using Random
using Test

Random.seed!(63)

## 54000 seconds

city = read_city();
city.total_duration

@time solution = fast_random_walk_repeated(city; trials=10);
@test is_feasible(solution, city)
distance = total_distance(solution, city)

ub = flow_upper_bound(city)
@test distance <= ub

# write_solution(
#     solution,
#     joinpath(@__DIR__, "..", "solution", "solution_$distance.txt"),
# )

## 18000 seconds

city_small = City(;
    total_duration=city.total_duration ÷ 3,
    nb_cars=city.nb_cars,
    starting_junction=city.starting_junction,
    junctions=city.junctions,
    streets=city.streets,
);
city_small.total_duration

@time solution_small = fast_random_walk_repeated(city_small; trials=10);
@test is_feasible(solution_small, city_small)
distance_small = total_distance(solution_small, city_small)

ub_small = flow_upper_bound(city_small)
@test distance_small <= ub_small

# write_solution(
#     solution_small,
#     joinpath(@__DIR__, "..", "solution", "solution_small_$distance.txt"),
# )
