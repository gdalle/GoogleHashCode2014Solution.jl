### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 3e96add0-6f79-11ef-1a8d-934bd326992a
begin
	using GoogleHashCode2014
	using PlutoUI
	using ProgressLogging
	using PythonCall
	using Random
	using Statistics
	using StatsBase
end

# ╔═╡ 5c96fdb3-bda1-4bd9-9021-aa643131bd62
TableOfContents()

# ╔═╡ 4e108f85-268e-4797-a7b5-af8ff44deb1c
md"""
# Better structures
"""

# ╔═╡ a61031d9-3a4c-4c05-bcc0-b1d0f1cc65b2
md"""
## City
"""

# ╔═╡ d1a03997-81c2-4dfd-aeb8-d46081dc4f6e
begin
	struct BetterCity
	    city::City
		# junction index -> vector of street indices
	    connections::Dict{Int,Vector{Int}}
		# pair of junction indices -> street index
		street_indices::Dict{Tuple{Int,Int},Int}
	end
	
	function BetterCity(city::City)
	    connections = Dict{Int,Vector{Int}}()
	    street_indices = Dict{Tuple{Int,Int},Int}()
	    for (s, street) in enumerate(city.streets)
	        (; endpointA, endpointB, bidirectional) = street
			street_indices[endpointA, endpointB] = s
	        if !haskey(connections, endpointA)
	            connections[endpointA] = [s]
	        else
	            push!(connections[endpointA], s)
	        end
	        if bidirectional
				street_indices[endpointB, endpointA] = s
	            if !haskey(connections, endpointB)
	                connections[endpointB] = [s]
	            else
	                push!(connections[endpointB], s)
	            end
	        end
	    end
	    return BetterCity(city, connections, street_indices)
	end
end

# ╔═╡ e8751422-5081-42a3-b008-1c94af785fdf
function adjacent_streets(j::Integer, bcity::BetterCity)
    return bcity.connections[j]
end

# ╔═╡ 12e298bf-93d2-43ad-8cc7-e5d41b02f0c2
function street_from_pair(i::Integer, j::Integer, bcity::BetterCity)
    return bcity.street_indices[i, j]
end

# ╔═╡ 32e421be-6c7b-44b7-9f1a-cc0002b89048
md"""
## Solution
"""

# ╔═╡ f800f598-b9c1-4fe9-8fb5-1e9775c4f35b
begin
	struct BetterSolution
	    solution::Solution
	    junctions_visited::Vector{Int}
	    streets_visited::Vector{Int}
	end
	
	function BetterSolution(bcity::BetterCity)
	    (; city) = bcity
	    itineraries = [[city.starting_junction] for c in 1:(city.nb_cars)]
	    solution = Solution(itineraries)
	    junctions_visited = zeros(Int, length(city.junctions))
	    junctions_visited[city.starting_junction] = 1
	    streets_visited = zeros(Int, length(city.streets))
	    return BetterSolution(solution, junctions_visited, streets_visited)
	end
end

# ╔═╡ 6bff5fbf-67e7-43c4-86f9-7d68087b1c4a
function current_junction(c::Integer, bsolution::BetterSolution)
    return last(bsolution.solution.itineraries[c])
end

# ╔═╡ c88a0edf-62ed-4d59-ac1a-2d0fa02b9785
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
    junctions_visited[j] += 1
    streets_visited[s] += 1
    return nothing
end

# ╔═╡ 7fd93586-6866-496f-b181-089041773506
function fast_total_distance(bsolution::BetterSolution, bcity::BetterCity)
	(; city) = bcity
	(; solution, streets_visited) = bsolution
	streets_counted = falses(length(streets_visited))
	dist = 0
	for c in 1:city.nb_cars
		itinerary = solution.itineraries[c]
		for k in 1:length(itinerary)-1
			i, j = itinerary[k], itinerary[k+1]
			s = street_from_pair(i, j, bcity)
			if !streets_counted[s]
				dist += city.streets[s].distance
				streets_counted[s] = true
			end
		end
	end
	return dist
end

# ╔═╡ ddab3289-c951-4400-8005-5b31a29f7197
md"""
# Greedy algorithm
"""

# ╔═╡ 2732139c-6e5e-4907-9ace-f22095d830dd
md"""
# Experiments
"""

# ╔═╡ 15f9c4f8-330a-4e72-82ae-d5b8399252b4
city = read_city()

# ╔═╡ 50c0ab69-621c-40e9-9b47-cac14953c2c1
bcity = BetterCity(city)

# ╔═╡ 91d3dc65-3b0c-475a-a5e5-862bc498827e
md"""
## Fitness function
"""

# ╔═╡ 81b53137-843f-4349-8712-db9d1c0f7f6c
function fitness(
	c::Integer,  # index of the car
	s::Integer,  # index of the street it might take
	bsolution::BetterSolution,  # enhanced solution
	bcity::BetterCity  # enhanced city
)
	city = bcity.city  # usual City object
	solution = bsolution.solution  # usual Solution object
	street = city.streets[s]  # street that car c might possibly take (which you're scoring)
	itinerary = solution.itineraries[c]  # itinerary of car c so far
	speed = street.distance / street.duration
	i = last(itinerary)  # current junction index
	j = get_street_end(i, street)  # possible next junction index
	this_junction = city.junctions[i]
	next_junction = city.junctions[j]
	this_latitude, this_longitude = this_junction.latitude, this_junction.longitude
	next_latitude, next_longitude = next_junction.latitude, next_junction.longitude

	# use all of this to design a good score
    score = 1 - 0.8 * (bsolution.streets_visited[s] > 0)
	return score
end

# ╔═╡ 616d49cc-a61f-4923-ad0b-286d7bb36b05
function greedy_random_walk(rng::AbstractRNG, bcity::BetterCity)
	(; city) = bcity
    # create better data structures
    bsolution = BetterSolution(bcity)

	# loop over all cars
    for c in 1:(city.nb_cars)
		# start with an empty itinerary
        current_duration = 0
        while true
            i = current_junction(c, bsolution)
			# indices of all streets that I can take from junction i
            street_index_candidates = [
                s for s in adjacent_streets(i, bcity) if
                current_duration + city.streets[s].duration <= city.total_duration
            ]
			# fitness scores of these streets
            street_index_scores = [
				fitness(c, s, bsolution, bcity) for s in street_index_candidates
			]
            if isempty(street_index_candidates)
				# we don't have enough time left, stop and go to next car
                break
            else
				# pick a candidate with a probability that grows with its score
				weights = max.(street_index_scores, 0)
				weights ./= sum(weights)
                s = wsample(rng, street_index_candidates, weights)
				# update the solution
                append_street!(bsolution, c, s, bcity)
                current_duration += city.streets[s].duration
            end
        end
    end
    return bsolution
end

# ╔═╡ 7354ed48-3190-43e0-866b-d54f97e8b022
md"""
## Result
"""

# ╔═╡ 78145f50-6d63-48fe-ad96-f664473f5c2b
nb_solutions = 10

# ╔═╡ 549a642e-848c-482e-a3e1-d4938a5b9a85
bsolutions = let
	rng = Random.MersenneTwister(0)
	bsolutions = Vector{BetterSolution}(undef, nb_solutions)
	@progress for k in eachindex(bsolutions)
		bsolutions[k] = greedy_random_walk(rng, bcity)
	end
	bsolutions
end

# ╔═╡ 9f703981-bae1-4810-8a25-85dc6579256d
total_distance_interval = let
	city = read_city()
	dists = similar(bsolutions, Int)
	@progress for (k, bsolution) in enumerate(bsolutions)
		dists[k] = fast_total_distance(bsolution, bcity)
	end
	μ, σ = mean(dists), std(dists)
	(μ - σ, μ + σ)
end

# ╔═╡ ae3b6f70-e2c1-498e-80c3-880cb53d81ef
md"""
## Plots
"""

# ╔═╡ e7a8b809-d357-401d-b3d2-a978ad6887ab
plot_streets(city, bsolutions[1].solution)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
GoogleHashCode2014 = "a405283a-0100-47ff-b2ed-5493eb4224b2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
PythonCall = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
GoogleHashCode2014 = "~0.2.3"
PlutoUI = "~0.7.60"
ProgressLogging = "~0.1.4"
PythonCall = "~0.9.23"
StatsBase = "~0.34.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "39abb2033051679c28a7777805a2a43465c6a141"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.CondaPkg]]
deps = ["JSON3", "Markdown", "MicroMamba", "Pidfile", "Pkg", "Preferences", "TOML"]
git-tree-sha1 = "8f7faef2ca039ee068cd971a80ccd710d23fb2eb"
uuid = "992eb4ea-22a4-4c89-a5bb-47a3300528ab"
version = "0.2.23"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.GoogleHashCode2014]]
deps = ["Artifacts", "Random"]
git-tree-sha1 = "c90c21ef89a0aa8595e4eef9baf752206f3a4120"
uuid = "a405283a-0100-47ff-b2ed-5493eb4224b2"
version = "0.2.3"
weakdeps = ["PythonCall"]

    [deps.GoogleHashCode2014.extensions]
    GoogleHashCode2014PythonCallExt = "PythonCall"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "f389674c99bfcde17dc57454011aa44d5a260a40"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.MicroMamba]]
deps = ["Pkg", "Scratch", "micromamba_jll"]
git-tree-sha1 = "011cab361eae7bcd7d278f0a7a00ff9c69000c51"
uuid = "0b3b1443-0f03-428d-bdfb-f27f9c1191ea"
version = "0.1.14"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pidfile]]
deps = ["FileWatching", "Test"]
git-tree-sha1 = "2d8aaf8ee10df53d0dfb9b8ee44ae7c04ced2b03"
uuid = "fa939f87-e72e-5be4-a000-7fc836dbe307"
version = "1.3.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

[[deps.PythonCall]]
deps = ["CondaPkg", "Dates", "Libdl", "MacroTools", "Markdown", "Pkg", "REPL", "Requires", "Serialization", "Tables", "UnsafePointers"]
git-tree-sha1 = "06a778ec6d6e76b0c2fb661436a18bce853ec45f"
uuid = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
version = "0.9.23"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "159331b30e94d7b11379037feeb9b690950cace8"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafePointers]]
git-tree-sha1 = "c81331b3b2e60a982be57c046ec91f599ede674a"
uuid = "e17b2a0c-0bdf-430a-bd0c-3a23cae4ff39"
version = "1.0.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.micromamba_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "b4a5a3943078f9fd11ae0b5ab1bdbf7718617945"
uuid = "f8abcde7-e9b7-5caa-b8af-a437887ae8e4"
version = "1.5.8+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═3e96add0-6f79-11ef-1a8d-934bd326992a
# ╠═5c96fdb3-bda1-4bd9-9021-aa643131bd62
# ╟─4e108f85-268e-4797-a7b5-af8ff44deb1c
# ╟─a61031d9-3a4c-4c05-bcc0-b1d0f1cc65b2
# ╟─d1a03997-81c2-4dfd-aeb8-d46081dc4f6e
# ╟─e8751422-5081-42a3-b008-1c94af785fdf
# ╟─12e298bf-93d2-43ad-8cc7-e5d41b02f0c2
# ╟─32e421be-6c7b-44b7-9f1a-cc0002b89048
# ╟─f800f598-b9c1-4fe9-8fb5-1e9775c4f35b
# ╟─6bff5fbf-67e7-43c4-86f9-7d68087b1c4a
# ╟─c88a0edf-62ed-4d59-ac1a-2d0fa02b9785
# ╟─7fd93586-6866-496f-b181-089041773506
# ╟─ddab3289-c951-4400-8005-5b31a29f7197
# ╠═616d49cc-a61f-4923-ad0b-286d7bb36b05
# ╟─2732139c-6e5e-4907-9ace-f22095d830dd
# ╠═15f9c4f8-330a-4e72-82ae-d5b8399252b4
# ╠═50c0ab69-621c-40e9-9b47-cac14953c2c1
# ╟─91d3dc65-3b0c-475a-a5e5-862bc498827e
# ╠═81b53137-843f-4349-8712-db9d1c0f7f6c
# ╟─7354ed48-3190-43e0-866b-d54f97e8b022
# ╠═78145f50-6d63-48fe-ad96-f664473f5c2b
# ╟─549a642e-848c-482e-a3e1-d4938a5b9a85
# ╟─9f703981-bae1-4810-8a25-85dc6579256d
# ╟─ae3b6f70-e2c1-498e-80c3-880cb53d81ef
# ╠═e7a8b809-d357-401d-b3d2-a978ad6887ab
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
