using HashCode2014
using HashCode2014Solution
using Test

city = read_city();
city_shorter = change_duration(city, 18000)

ub1 = flow_upper_bound(city)
ub2 = flow_upper_bound(city_shorter)

@test ub1 == naive_upper_bound(city)
@test ub2 < naive_upper_bound(city_shorter)

@info "Flow upper bound (15h): $(round(Int,ub1))"
@info "Flow upper bound (5h): $(round(Int,ub2))"
