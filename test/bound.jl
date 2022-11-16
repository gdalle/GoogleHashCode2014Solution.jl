using HashCode2014
using HashCode2014Solution

city = read_city()

@test knapsack_upper_bound(city) == sum(street.distance for street in city.streets)

sum(street.duration for street in city.streets)
city.nb_cars * city.total_duration
