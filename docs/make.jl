using Documenter: Documenter, DocMeta, deploydocs, makedocs
using PkgDependents: PkgDependents

DocMeta.setdocmeta!(PkgDependents, :DocTestSetup, :(using PkgDependents); recursive = true)

include("make_index.jl")

makedocs(;
    modules = [PkgDependents],
    authors = "ITensor developers <support@itensor.org> and contributors",
    sitename = "PkgDependents.jl",
    format = Documenter.HTML(;
        canonical = "https://itensor.github.io/PkgDependents.jl",
        edit_link = "main",
        assets = ["assets/favicon.ico", "assets/extras.css"]
    ),
    pages = ["Home" => "index.md", "Reference" => "reference.md"]
)

deploydocs(;
    repo = "github.com/ITensor/PkgDependents.jl", devbranch = "main", push_preview = true
)
