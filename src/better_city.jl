struct BetterCity
    city::City
    connections::Dict{Int,Vector{Int}}
end

function BetterCity(city::City)
    connections = Dict{Int,Vector{Int}}()
    for (k, street) in enumerate(city.streets)
        (; endpointA, endpointB, bidirectional) = street
        if !haskey(connections, endpointA)
            connections[endpointA] = [k]
        else
            push!(connections[endpointA], k)
        end
        if bidirectional
            if !haskey(connections, endpointB)
                connections[endpointB] = [k]
            else
                push!(connections[endpointB], k)
            end
        end
    end
    return BetterCity(city, connections)
end

function adjacent_streets(j::Integer, bcity::BetterCity)
    return bcity.connections[j]
end

function street_from_pair(i::Integer, j::Integer, bcity::BetterCity)
    for s in adjacent_streets(bcity, i)
        street = bcity.city.streets[s]
        if is_street(i, j, street)
            return street
        end
    end
    throw(ArgumentError("Junction pair $((i, j)) does not correspond to any street."))
end
