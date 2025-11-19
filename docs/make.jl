using Magika
using Documenter

DocMeta.setdocmeta!(Magika, :DocTestSetup, :(using Magika); recursive=true)

makedocs(;
    modules=[Magika],
    authors="imohag9 <souidi.hamza90@gmail.com> and contributors",
    sitename="Magika.jl",
    format=Documenter.HTML(;
        canonical="https://imohag9.github.io/Magika.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Basic Usage" => "basic_usage.md",
        "Advanced Usage" => "advanced_usage.md",
        "Understanding Results" => "understanding_results.md",
        "API Reference" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/imohag9/Magika.jl",
    devbranch="main",
)
