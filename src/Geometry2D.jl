# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""
Geometry2D models basic geometric shapes and common geometric formulae.
This is a flat module with entities grouped into similar files under `src`.

See online documentation at https://mechanomy.github.io/Geometry2D.jl/dev/ and [test](https://github.com/mechanomy/Geometry2D.jl/tree/main/test) for examples of each function.
"""
module Geometry2D

  using TestItems

  using UnitTypes
  # include("../../UnitTypes_public/src/UnitTypes.jl")
  # using .UnitTypes

  # using DimensionfulAngles # https://github.com/cmichelenstrofer/DimensionfulAngles.jl
  using KeywordDispatch
  using RecipesBase
  using DocStringExtensions # https://docstringextensions.juliadocs.org/latest/ how to make this a doc dependency?

  # __precompile__(false) # don't precompile during dev

  include("Angle.jl")
  include("Point2D.jl") 
  include("Vector2D.jl")
  include("Triangle2D.jl")
  include("Circle2D.jl")
  include("Spiral2D.jl")
  include("Transform2D.jl")

  include("Ellipse2D.jl") #waiting on a segfault to resolve https://github.com/JeffreySarnoff/ArbNumerics.jl/issues/68

  include("Point3D.jl") 
end; 

