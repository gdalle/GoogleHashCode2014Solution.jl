using Aqua
using HashCode2014
using HashCode2014Solution
using JuliaFormatter
using Random
using Test

Random.seed!(63)

@testset verbose = true "HashCode2014Solution.jl" begin
    @testset verbose = true "Code quality (Aqua.jl)" begin
        Aqua.test_all(
            HashCode2014Solution; ambiguities=false, deps_compat=(; check_extras=false)
        )
    end
    @testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
        @test format(HashCode2014Solution; verbose=false, overwrite=false)
    end
    @testset verbose = true "Graph" begin
        include("graph.jl")
    end
    @testset verbose = true "Random walk" begin
        include("random.jl")
    end
    @testset verbose = true "Knapsack upper bound" begin
        include("knapsack.jl")
    end
    @testset verbose = true "Flow upper bound" begin
        include("flow.jl")
    end
end
