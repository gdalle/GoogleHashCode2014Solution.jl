function fast_random_walk(rng::AbstractRNG, city::City)
    (; total_duration, nb_cars, starting_junction) = city
    g = CityGraph(city)
    itineraries = Vector{Vector{Int}}(undef, nb_cars)
    for c in 1:nb_cars
        itinerary = [starting_junction]
        duration = 0
        while true
            i = last(itinerary)
            candidates = [
                j for j in outneighbors(g, i) if
                duration + get_duration(g, i, j) <= total_duration
            ]
            if isempty(candidates)
                break
            else
                j = rand(rng, candidates)
                push!(itinerary, j)
                duration += get_duration(g, i, j)
            end
        end
        itineraries[c] = itinerary
    end
    return Solution(itineraries)
end

function fast_random_walk_repeated(rng::AbstractRNG, city::City; trials=10)
    solutions = Solution[]
    distances = Int[]
    @progress for _ in 1:trials
        solution = fast_random_walk(rng, city)
        distance = total_distance(solution, city)
        push!(solutions, solution)
        push!(distances, distance)
    end
    return solutions[argmax(distances)]
end
