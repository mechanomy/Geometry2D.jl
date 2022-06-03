# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


module Geometry2D
  using Test
  using Unitful, Unitful.DefaultSymbols
  # using PyPlot #can use matplotlib arguments directly
  # using Printf
  # using StaticArrays #for defined-length arrays: SVector{3,T}
  # using QuadGK #for numerical integration of ellipseArcLength
  using KeywordDispatch

  # re module layout,
  #cf: https://discourse.julialang.org/t/ann-patmodules-jl-a-better-module-system-for-julia/52226/40
  #
  include("Unitfuller.jl")
  include("Point2D.jl") #bring all of Point2D.jl into the Geometry2D module, Point2D.jl is not a module, just a file of lines
  include("Vector2D.jl")
  include("Triangle2D.jl")
  include("Circle2D.jl")
  include("Ellipse2D.jl")
  include("Transform2D.jl")


  # function angleCorrect(angle::Radian)
  #     return (ustrip(angle) + 2*pi)%(2*pi) * 1.0u"rad"
  # end
  # function angleCorrect(angle)
  #     return (angle + 2*pi)%(2*pi)
  # end
   

end; #Geometry2D

