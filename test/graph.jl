using HashCode2014
using HashCode2014Solution
using Test

city = read_city();

g = CityGraph(city)

@test HashCode2014Solution.nv(g) == length(city.junctions)
@test HashCode2014Solution.ne(g) ==
    length(city.streets) + sum(street.bidirectional for street in city.streets)
