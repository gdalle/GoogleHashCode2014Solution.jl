struct CityGraph
    durations::SparseMatrixCSC{Int,Int}
    distances::SparseMatrixCSC{Int,Int}
end

nv(g::CityGraph) = size(g.durations, 1)
ne(g::CityGraph) = nnz(g.durations)

function edges(g::CityGraph)
    (I, J, _) = findnz(g.durations)
    return zip(I, J)
end

has_edge(g, i, j) = g.durations[i, j] > 0

get_duration(g::CityGraph, i, j) = g.durations[i, j]
get_distance(g::CityGraph, i, j) = g.distances[i, j]

outneighbors(g::CityGraph, i) = g.durations[i, :].nzind
inneighbors(g::CityGraph, j) = g.durations[:, j].nzind

function CityGraph(city::City)
    n = length(city.junctions)
    I, J = Int[], Int[]
    durations_values, distances_values = Int[], Int[]
    for street in city.streets
        (; endpointA, endpointB, duration, distance, bidirectional) = street
        push!(I, endpointA)
        push!(J, endpointB)
        push!(durations_values, duration)
        push!(distances_values, distance)
        if bidirectional
            push!(I, endpointB)
            push!(J, endpointA)
            push!(durations_values, duration)
            push!(distances_values, distance)
        end
    end
    durations = sparse(I, J, durations_values, n, n)
    distances = sparse(I, J, distances_values, n, n)
    return CityGraph(durations, distances)
end
