speed(street::Street) = street.distance / street.duration

function knapsack_upper_bound(city::City)
    sorted_streets = sort(city.streets; by=speed, rev=true)
    s = 1
    current_distance = 0
    current_duration = 0
    while (
        s <= length(sorted_streets) &&
        current_duration <= city.nb_cars * city.total_duration
    )
        current_distance += sorted_streets[s].distance
        current_duration += sorted_streets[s].duration
        s += 1
    end
    return current_distance
end
