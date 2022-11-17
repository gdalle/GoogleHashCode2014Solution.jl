using HiGHS
using JuMP
using HashCode2014
using HashCode2014Solution
using ProgressLogging
using SparseArrays

function flow_upper_bound(city::City; integer=true)
    g = CityGraph(city)

    C = city.nb_cars
    T = city.total_duration

    E = collect(edges(g))
    E_out = [(v, nv(g) + 1) for v in 1:nv(g)]
    all_E = vcat(E, E_out)

    model = Model(HiGHS.Optimizer)

    @variable(model, 0 <= x[all_E] <= C)
    @variable(model, 0 <= y[all_E] <= 1)

    if integer
        set_integer.(x)
        set_integer.(y)
    end

    @objective(model, Max, sum(y[(u, v)] * get_distance(g, u, v) for (u, v) in E))

    @constraint(model, sum(x[(u, v)] * get_duration(g, u, v) for (u, v) in E) <= C * T)

    for (u, v) in E
        if (u > v) && has_edge(g, v, u)
            @constraint(model, y[(u, v)] == 0)
        else
            @constraint(model, y[(u, v)] <= x[(u, v)])
            @constraint(model, x[(u, v)] <= C .* y[(u, v)])
        end
    end

    @progress for v in 1:nv(g)
        inflow = sum(x[(u, v)] for u in inneighbors(g, v); init=0)
        outflow = x[(v, nv(g) + 1)] + sum(x[(v, w)] for w in outneighbors(g, v); init=0)
        if v == city.starting_junction
            @constraint(model, inflow + C == outflow)
        else
            @constraint(model, inflow == outflow)
        end
    end
    @constraint(model, sum(x[(v, nv(g) + 1)] for v in 1:nv(g)) == C)

    optimize!(model)
    return objective_value(model)
end
