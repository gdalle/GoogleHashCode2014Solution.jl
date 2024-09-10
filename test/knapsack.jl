using GoogleHashCode2014
using GoogleHashCode2014Solution
using Test

city = read_city();
city_shorter = change_duration(city, 18000)

ub1 = knapsack_upper_bound(city)
ub2 = knapsack_upper_bound(city_shorter)

@test ub1 == naive_upper_bound(city)
@test ub2 < naive_upper_bound(city_shorter)

@info "Knapsack upper bound (15h): $ub1"
@info "Knapsack upper bound (5h): $ub2"
