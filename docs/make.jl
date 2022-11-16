using HashCode2014Solution
using Documenter

DocMeta.setdocmeta!(
    HashCode2014Solution,
    :DocTestSetup,
    :(using HashCode2014Solution);
    recursive = true,
)

makedocs(;
    modules = [HashCode2014Solution],
    authors = "Guillaume Dalle <22795598+gdalle@users.noreply.github.com> and contributors",
    repo = "https://github.com/gdalle/HashCode2014Solution.jl/blob/{commit}{path}#{line}",
    sitename = "HashCode2014Solution.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://gdalle.github.io/HashCode2014Solution.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = ["Home" => "index.md", "API reference" => "api.md"],
)

deploydocs(; repo = "github.com/gdalle/HashCode2014Solution.jl", devbranch = "main")
