function fitness(c::Integer, s::Integer, bsolution::BetterSolution, bcity::BetterCity)
    return 1 - 0.7 * bsolution.streets_visited[s]
end

function greedy_random_walk(rng::AbstractRNG, city::City)
    bcity = BetterCity(city)
    bsolution = BetterSolution(bcity)
    for c in 1:(city.nb_cars)
        current_duration = 0
        while true
            i = current_junction(c, bsolution)
            candidates = [
                s for s in adjacent_streets(i, bcity) if
                current_duration + city.streets[s].duration <= city.total_duration
            ]
            scores = [fitness(c, s, bsolution, bcity) for s in candidates]
            if isempty(candidates)
                break
            else
                s = wsample(rng, candidates, scores)
                append_street!(bsolution, c, s, bcity)
                current_duration += city.streets[s].duration
            end
        end
    end
    return bsolution.solution
end
