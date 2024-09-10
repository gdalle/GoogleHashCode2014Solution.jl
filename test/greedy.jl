using GoogleHashCode2014
using GoogleHashCode2014Solution
using Random
using Test

city = read_city();

solution = greedy_random_walk(Random.MersenneTwister(0), city)
@test total_distance(solution, city) > 1e6
@test is_feasible(solution, city)
