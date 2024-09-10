struct BetterSolution
    solution::Solution
    junctions_visited::Vector{Bool}
    streets_visited::Vector{Bool}
end

function BetterSolution(bcity::BetterCity)
    (; city) = bcity
    itineraries = [[city.starting_junction] for c in 1:(city.nb_cars)]
    solution = Solution(itineraries)
    junctions_visited = falses(length(city.junctions))
    junctions_visited[city.starting_junction] = true
    streets_visited = falses(length(city.streets))
    return BetterSolution(solution, junctions_visited, streets_visited)
end

function current_junction(c::Integer, bsolution::BetterSolution)
    return last(bsolution.solution.itineraries[c])
end

function append_street!(
    bsolution::BetterSolution, c::Integer, s::Integer, bcity::BetterCity
)
    (; solution, junctions_visited, streets_visited) = bsolution
    street = bcity.city.streets[s]
    i = current_junction(c, bsolution)
    if is_street_start(i, street)
        j = get_street_end(i, street)
        push!(solution.itineraries[c], j)
    end
    junctions_visited[j] = true
    streets_visited[s] = true
    return nothing
end
