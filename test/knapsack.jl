using HashCode2014
using HashCode2014Solution
using Test

city = read_city();

ub = knapsack_upper_bound(city)

@test ub <= sum(street.distance for street in city.streets)

@test sum(street.duration for street in city.streets) <= city.nb_cars * city.total_duration
