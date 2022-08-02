# following https://juliadocs.github.io/Documenter.jl/stable/man/guide/

using Documenter
using DocStringExtensions
using Geometry2D


# https://github.com/cscherrer/MeasureTheory.jl/blob/master/docs/make.jl
# DocMeta.setdocmeta!(BeltTransmission, :DocTestSetup, :(using BeltTransmission); recursive = true)

makedocs(
  sitename="Geometry2D.jl",
  modules=[Geometry2D],
  root = joinpath(dirname(pathof(Geometry2D)), "..", "docs"),
  source = "src",
  build = "build",
  clean=true,
  doctest=true,
  repo = "github.com/mechanomy/Geometry2D.jl.git",
  draft=false,
  checkdocs=:all,
  # linkcheck=true, fails to find internal links to bookmarks..
  )

deploydocs(
  root = joinpath(dirname(pathof(Geometry2D)), "..", "docs"),
  target = "build",
  dirname = "",
  repo = "github.com/mechanomy/Geometry2D.jl.git",
  branch = "gh-pages",
  deps = nothing, 
  make = nothing,
  devbranch = "main",
  devurl = "dev",
  versions = ["stable" => "v^", "v#.#", devurl => devurl],
  forcepush = false,
  deploy_config = auto_detect_deploy_system(),
  push_preview = false,
  repo_previews = repo,
  branch_previews = branch,
)

