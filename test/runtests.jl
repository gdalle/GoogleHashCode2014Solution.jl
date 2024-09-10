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
    @testset "Greedy algorithm" begin
        include("greedy.jl")
    end
end
