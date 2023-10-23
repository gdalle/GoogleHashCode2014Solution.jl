using HashCode2014
using HashCode2014Solution
using Test
using Random

city = read_city();
city_shorter = change_duration(city, 18000)

rng = MersenneTwister(63)
trials = 10
stats1 = @timed fast_random_walk_repeated(rng, city; trials=trials)
stats2 = @timed fast_random_walk_repeated(rng, city_shorter; trials=trials)

sol1, time1 = stats1.value, stats1.time
sol2, time2 = stats2.value, stats2.time

@test is_feasible(sol1, city)
@test is_feasible(sol2, city_shorter)

dist1 = total_distance(sol1, city)
dist2 = total_distance(sol2, city_shorter)

@info "Solution value (15h): $dist1 - CPU time $(time1)s"
@info "Solution value (5h): $dist2 - CPU time $(time2)s"
