# following https://juliadocs.github.io/Documenter.jl/stable/man/guide/

using Documenter
using DocStringExtensions
using Geometry2D


# https://github.com/cscherrer/MeasureTheory.jl/blob/master/docs/make.jl
# DocMeta.setdocmeta!(BeltTransmission, :DocTestSetup, :(using BeltTransmission); recursive = true)

makedocs(
  sitename="Geometry2D.jl",
  modules=[Geometry2D] 
  )
