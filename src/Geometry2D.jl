
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
    include("Circle2D.jl")
    include("Ellipse2D.jl")
    # include("TransformationMatrices2D.jl")

    # using BPlot

    # const UnitVector{T} = SVector{3,T}
    # const ui = UnitVector([1,0,0])
    # const uj = UnitVector([0,1,0])
    # const uk = UnitVector([0,0,1])

   # function normalize( vec ) #LinearAlgebra.normalize messes up the units..
    #     return vec / norm(vec)
    # end
    # function length( vec )
    #     return norm(vec)
    # end
    # # # returns true if a == b within tol, or abs(a)-abs(b) < tol
    # # function eqTol(a::Number, b::Number, tol::Number=1e-3)
    # #     return abs(ustrip(a)-ustrip(b)) <= ustrip(tol)
    # # end

    # function angleCorrect(angle::Radian)
    #     return (ustrip(angle) + 2*pi)%(2*pi) * 1.0u"rad"
    # end
    # function angleCorrect(angle)
    #     return (angle + 2*pi)%(2*pi)
    # end

    # """
    # Compute a circlular arc length at `radius` through `angle`
    # ```
    # angle = 20u"°" 
    # radius = 5u"mm"
    # len = circleArcLength(angle, radius)
    # ```
    # """
    # function circleArcLength( angle::Angle, radius::Unitful.Length )
    #     return uconvert(u"rad", angle) * radius
    # end

    # """
    # A more explicit trig function
    # """
    # function angleOpposite2Adjacent(angle::Angle, opposite::Unitful.Length)
    #     return opposite / tan(angle)
    # end
    # function angleAdjacent2Opposite(angle::Angle, adjacent::Unitful.Length)
    #     return adjacent * tan(angle)
    # end
    # """
    # Finds the length of the unknown `legC` from `legA`, `legB`, and `angleAB` between them
    # """
    # function lawOfCosines(legA::Unitful.Length, legB::Unitful.Length, angleAB::Angle)
    #     return sqrt( legA^2 + legB^2 -2*legA*legB*cos(angleAB))
    # end
    # """
    # For any triangle with legs A, B, C and angles AB, BC, CA, so that `legA` is the open side of `angleBC`, finds legB corresponding to `angleCA`
    # """
    # function lawOfSines(legA::Unitful.Length, angleBC::Angle, angleCA::Angle, showDiagram=false)
    #     if showDiagram
    #         fig2 = figure()

    #         abc = uconvert(u"rad", angleBC)
    #         aca = uconvert(u"rad", angleCA)
    #         aab = (pi - abc - aca)u"rad"
    #         angleAB = uconvert(u"°", aab)

    #         # legA = 1u"m"
    #         legB = legA * sin(aca)/sin(abc)
    #         legC = legA * sin(aab)/sin(abc)

    #         vCA = [0;0]u"m" #vertex of angleCA
    #         vAB = vCA + legA*[cos(aca); sin(aca)]
    #         vBC = vCA + legA*[cos(aca); sin(aca)] + legB*[cos(abc); -sin(abc)]

    #         plot([ustrip(vAB[1]), ustrip(vBC[1])], [ustrip(vAB[2]), ustrip(vBC[2])], "bo-", ls="-", c="b") #[a,b] to make vectors, [a b] makes matrix
    #         plot([ustrip(vCA[1]), ustrip(vBC[1])], [ustrip(vCA[2]), ustrip(vBC[2])], "co-", ls="-", c="c")
    #         plot([ustrip(vAB[1]), ustrip(vCA[1])], [ustrip(vAB[2]), ustrip(vCA[2])], "mo-", ls="-", c="m")
    #         avg = mean([vAB, vBC])
    #         txtB = @sprintf("%3.3fmm", ustrip(u"mm", legB))
    #         text(ustrip(avg[1]), ustrip(avg[2]), "B[$txtB]", color="b", backgroundcolor=(1,1,1,0.5), alpha=0.8)
    #         avg = mean([vBC, vCA])
    #         txtC = @sprintf("%3.3fmm", ustrip(u"mm", legC))
    #         text(ustrip(avg[1]), ustrip(avg[2]), "C[$txtC]", color="c", backgroundcolor=(1,1,1,0.5), alpha=0.8)
    #         avg = mean([vCA, vAB])
    #         txtA = @sprintf("%3.3fmm", ustrip(u"mm", legA))
    #         text(ustrip(avg[1]), ustrip(avg[2]), "A[$txtA]", color="m", backgroundcolor=(1,1,1,0.5), alpha=0.8)
    #         text(ustrip(vAB[1]),ustrip(vAB[2]),"AB[$(uconvert(u"°",angleAB))]", color="c")
    #         text(ustrip(vBC[1]),ustrip(vBC[2]),"BC[$(uconvert(u"°",angleBC))]", color="m")
    #         text(ustrip(vCA[1]),ustrip(vCA[2]),"CA[$(uconvert(u"°",angleCA))]", color="b")
    #         title("lawOfSines()")
    #         ax = gca()
    #         ax.set_aspect("equal")
    #         grid()
    #     end
    #     return legA * sin(angleCA)/sin(angleBC)
    # end



       
    #line(40, start00, e angle)
    #make a conversion rule from Point to Point1? for easy use of Hs?
    # function angle(a::Point, b::Point)
    #     return atan(a.x-b.x, a.y-b.y) #make this a 360 axis reference..
    # end
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

