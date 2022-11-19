using HashCode2014
using HashCode2014Solution
using Test

city = read_city();

solution = fast_random_walk_repeated(city; trials=3)

@test is_feasible(solution, city)
distance = total_distance(solution, city)
