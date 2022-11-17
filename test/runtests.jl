using Aqua
using Documenter
using HashCode2014
using HashCode2014Solution
using JuliaFormatter
using Test

DocMeta.setdocmeta!(
    HashCode2014Solution, :DocTestSetup, :(using HashCode2014Solution); recursive=true
)

@testset verbose = true "HashCode2014Solution.jl" begin
    @testset verbose = true "Code quality (Aqua.jl)" begin
        Aqua.test_all(HashCode2014Solution; ambiguities=false)
    end
    @testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
        @test format(HashCode2014Solution; verbose=true, overwrite=false)
    end
    @testset verbose = true "Doctests (Documenter.jl)" begin
        doctest(HashCode2014Solution)
    end
    @testset verbose = true "Graph" begin
        include("graph.jl")
    end
    @testset verbose = true "Random walk" begin
        include("random.jl")
    end
    @testset verbose = true "Knapsack UB" begin
        include("knapsack.jl")
    end
    @testset verbose = true "Flow UB" begin
        include("flow.jl")
    end
end
