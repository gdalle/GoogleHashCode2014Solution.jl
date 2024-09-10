module GoogleHashCode2014JuMPHiGHSExt

using GoogleHashCode2014
using HiGHS
using JuMP

function GoogleHashCode2014.flow_upper_bound(city::City; integer=false)
    g = CityGraph(city)
    C = city.nb_cars
    T = city.total_duration

    E_directed = collect(edges(g))
    E_directed_out = [(v, nv(g) + 1) for v in 1:nv(g)]
    E_undirected = union(
        [(u, v) for (u, v) in E_directed if u < v],
        [(v, u) for (u, v) in E_directed if v < u],
    )

    model = Model(HiGHS.Optimizer)

    @variable(model, 0 <= x[vcat(E_directed, E_directed_out)]; integer=integer)
    @variable(model, 0 <= y[E_undirected] <= 1; integer=integer)

    obj = AffExpr(0.0)
    for (u, v) in E_undirected
        if has_edge(g, u, v) && has_edge(g, v, u)
            add_to_expression!(obj, y[(u, v)] * get_distance(g, u, v))
            @constraint(model, y[(u, v)] <= x[(u, v)] + x[(v, u)])
        elseif has_edge(g, u, v)
            add_to_expression!(obj, y[(u, v)] * get_distance(g, u, v))
            @constraint(model, y[(u, v)] <= x[(u, v)])
        elseif has_edge(g, v, u)
            add_to_expression!(obj, y[(u, v)] * get_distance(g, v, u))
            @constraint(model, y[(u, v)] <= x[(v, u)])
        end
    end

    @objective(model, Max, obj)

    @constraint(
        model, sum(x[(u, v)] * get_duration(g, u, v) for (u, v) in E_directed) <= C * T
    )

    for v in 1:nv(g)
        inflow = AffExpr(0.0)
        for u in inneighbors(g, v)
            add_to_expression!(inflow, x[(u, v)])
        end
        outflow = AffExpr(0.0)
        add_to_expression!(outflow, x[(v, nv(g) + 1)])
        for u in outneighbors(g, v)
            add_to_expression!(outflow, x[(v, u)])
        end
        if v == city.starting_junction
            @constraint(model, inflow + C == outflow)
        else
            @constraint(model, inflow == outflow)
        end
    end
    set_silent(model)
    optimize!(model)
    return objective_value(model)
end

end
