function fast_random_walk(city::City)
    (; total_duration, nb_cars, starting_junction) = city
    g = create_graph(city)
    itineraries = Vector{Vector{Int}}(undef, nb_cars)
    for c in 1:nb_cars
        itinerary = [starting_junction]
        duration = 0
        while true
            i = last(itinerary)
            candidates = [
                j for j in outneighbors(g, i) if
                duration + get_data(g, i, j).duration <= total_duration
            ]
            if isempty(candidates)
                break
            else
                j = rand(candidates)
                push!(itinerary, j)
                duration += get_data(g, i, j).duration
            end
        end
        itineraries[c] = itinerary
    end
    return Solution(itineraries)
end

function fast_random_walk_repeated(city::City; trials=10)
    solutions = Solution[]
    distances = Int[]
    @progress for _ in 1:trials
        solution = fast_random_walk(city)
        distance = total_distance(solution, city)
        push!(solutions, solution)
        push!(distances, distance)
    end
    return solutions[argmax(distances)]
end
