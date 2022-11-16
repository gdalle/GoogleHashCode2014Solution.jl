function create_graph(city::City)
    T = Int
    VL = Float64
    VD = Tuple{Float64,Float64}
    ED = @NamedTuple{duration::Int, distance::Int}

    g = DataDiGraph{T,VL,VD,ED}((
        nb_cars=city.nb_cars,
        total_duration=city.total_duration,
        starting_junction=city.starting_junction,
    ))

    for junction in city.junctions
        label = rand()
        data = (junction.latitude, junction.longitude)
        @assert add_vertex!(g, label, data)
    end

    for street in city.streets
        s, d = street.endpointA, street.endpointB
        data = (duration=street.duration, distance=street.distance)
        @assert add_edge!(g, s, d, data)
        if street.bidirectional
            @assert add_edge!(g, d, s, data)
        end
    end

    return g
end
