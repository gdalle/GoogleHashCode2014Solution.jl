using Aqua
using GoogleHashCode2014
using GoogleHashCode2014Solution
using JuliaFormatter
using Random
using Test

Random.seed!(63)

@testset verbose = true "HashCode2014Solution.jl" begin
    @testset verbose = true "Code quality (Aqua.jl)" begin
        Aqua.test_all(
            GoogleHashCode2014Solution;
            ambiguities=false,
            deps_compat=(; check_extras=false),
        )
    end
    @testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
        @test format(GoogleHashCode2014Solution; verbose=false, overwrite=false)
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
