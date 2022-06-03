
module Geometry2D
using Test
    using LinearAlgebra #for cross(), dot(), norm()
    using Unitful, Unitful.DefaultSymbols
    using PyPlot #can use matplotlib arguments directly
    using Printf
    using StaticArrays #for defined-length arrays: SVector{3,T}
    # using QuadGK #for numerical integration of ellipseArcLength
    using KeywordDispatch
    using ArbNumerics

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


       
    # include("Line2D") #how does this differ from Vector2D?
    # struct Line
    #     a::Point
    #     b::Point
    #     angle::Angle
    #     length::Number
    # end
    # Line(a::Point, b::Point) = Line(a,b,angle(a,b),length(a-b))
    # function line(a::Point, length::Number, angle::Angle)::Line
    #     return Line(a, a + length*Point(cos(angle),sin(angle)))
    # end


    # box = [], where box is a Vector of Points or Lines
    # boxPrime = Rz * Tx * box



end; #Geometry2D

