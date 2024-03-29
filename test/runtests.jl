# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# using Pkg
# Pkg.activate( normpath(joinpath(@__DIR__, "..")) ) #activate this package

using Geometry2D

using Test

# using Unitful.DefaultSymbols

using Unitful
using Plots
# # pyplot()
# # close("all")


include("testVector2D.jl")
include("testTransform2D.jl")
include("testPoint2D.jl")
include("testCircle2D.jl")
include("testSpiral2D.jl")
include("testTriangle2D.jl")
include("testUnitfuller.jl")
include("testEllipse2D.jl") #there's a namespace collision somewhere in here that segfaults the terminal, if this occurs later

# using Unitful, Unitful.DefaultSymbols
# using Test
# using Plots
#   # re testing plots, https://discourse.julialang.org/t/how-to-test-plot-recipes/2648/4
#   @testset "Circle plotRecipe" begin
#     # pyplot()
#     gr()
#     c = Circle(1mm,2mm,3mm)
#     p = plot(c)
#     c = Circle(1mm,2mm,4mm)
#     p = plot!(c, linecolor=:red)
#     #pyplot:
#     # display(p) #display not configured for pyplot()
#     # show(p) #pyplot() doesn't show
#     #gr():
#     #  no plot by default
#     display(p) #produces a correct gk plot window
#     # show(p) #doesn't show

#     @test true
#   end



# close("all")

  
; #don't return the last thing