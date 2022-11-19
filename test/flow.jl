using HashCode2014
using HashCode2014Solution
using Test

city = read_city();

ub = flow_upper_bound(city)

@test ub == sum(street.distance for street in city.streets)
