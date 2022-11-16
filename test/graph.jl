using Graphs
using HashCode2014
using HashCode2014Solution

city = read_city()
g = create_graph(city)
@test nv(g) == length(city.junctions)
@test ne(g) == length(city.streets) + sum(street.bidirectional for street in city.streets)
