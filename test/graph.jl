using GoogleHashCode2014
using GoogleHashCode2014Solution
using Test

city = read_city();

g = CityGraph(city)

@test GoogleHashCode2014Solution.nv(g) == length(city.junctions)
@test GoogleHashCode2014Solution.ne(g) ==
    length(city.streets) + sum(street.bidirectional for street in city.streets)
