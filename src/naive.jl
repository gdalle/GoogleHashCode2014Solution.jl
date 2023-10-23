function naive_upper_bound(city::City)
    return sum(street.distance for street in city.streets)
end
