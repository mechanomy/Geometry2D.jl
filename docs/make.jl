# following https://juliadocs.github.io/Documenter.jl/stable/man/guide/

using Documenter
using DocumenterTools
using DocStringExtensions
using Geometry2D

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

# compile custom theme scss in to css, copying over the default themes
DocumenterTools.Themes.compile("docs/src/assets/themes/documenter-mechanomy.scss", "docs/build/assets/themes/documenter-dark.css")
DocumenterTools.Themes.compile("docs/src/assets/themes/documenter-mechanomy.scss", "docs/build/assets/themes/documenter-light.css")

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
  versions = ["stable" => "v^", "v#.#", "dev" => "dev"],
  forcepush = false,
  deploy_config = Documenter.auto_detect_deploy_system(),
  push_preview = false,
)

