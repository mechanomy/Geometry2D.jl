
# include("BPlot.jl")

module Geometry2D
    using LinearAlgebra #for cross(), dot(), norm()
    using Unitful
    using PyPlot #can use matplotlib arguments directly
    using Printf
    using StaticArrays #for defined-length arrays: SVector{3,T}

    using BPlot
    #import ..BPlot

    @derived_dimension Radian dimension(u"rad")
    const UnitVector{T} = SVector{3,T}
    const ui = UnitVector([1,0,0])
    const uj = UnitVector([0,1,0])
    const uk = UnitVector([0,0,1])

    struct Point
        x::Unitful.Length
        y::Unitful.Length
    end
    # Point(;x::Unitful.Length, y::Unitful.Length) = Point(x,y)
    # Point(;x::Number, y::Number) = Point( x*1.0u"mm", y*1.0u"mm" )

    # A circle has a <center::Geometry2D.Point> and a <radius::Unitful.Length>
    struct Circle
        center::Point #[x,y] of the pulley center
        radius::Unitful.Length
    end

    function plotCircle( circ::Circle, col )
        th = range(0,2*pi,length=100)
        x = ustrip(circ.center.x) .+ ustrip(circ.radius).*cos.(th)
        y = ustrip(circ.center.y) .+ ustrip(circ.radius).*sin.(th)
        plot(x,y, color=col, alpha=0.5 )
    end

    function vectorLengthAngle(length::Unitful.Length, angle::Radian)
        return length * [cos(angle); sin(angle); 0]
    end
    function normalize( vec ) #LinearAlgebra.normalize messes up the units..
        return vec / norm(vec)
    end
    function addPointVector(p::Point, v)
        return Point(p.x + v[1], p.y+v[2])
    end
    function subtractPoints(a::Point, b::Point)
        return [a.x - b.x; a.y-b.y; 0*a.x] # assume the units of a
    end
    #calculate the angle of the vector from a to b, as measured from 'horizontal'
    function angleBetweenPoints(a::Point, b::Point)
        d = subtractPoints(b,a)
        return atan(d[2],d[1])
    end

    # returns true if a == b within tol, or abs(a)-abs(b) < tol
    function eqTol(a::Number, b::Number, tol::Number=1e-3)
        return abs(ustrip(a)-ustrip(b)) <= ustrip(tol)
    end

    # isSegmentTangent(circleA, circleB, thA, thB) tests whether thA, thB define a segment tangent to the circle radii
    function isSegmentTangent( circleA::Circle, circleB::Circle, thA::Radian, thB::Radian, tol::Number=1e-3)
        rA = vectorLengthAngle(circleA.radius, thA)
        rB = vectorLengthAngle(circleB.radius, thB)
        uA = normalize(rA)
        uB = normalize(rB)

        pA = addPointVector( circleA.center, rA )
        pB = addPointVector( circleB.center, rB )
        rSeg = subtractPoints(pA, pB)
        uSeg = normalize(rSeg)
        crossA = cross([ustrip(uA[1]), ustrip(uA[2]), ustrip(uA[3])], [ustrip(uSeg[1]),ustrip(uSeg[2]),ustrip(uSeg[3])])
        crossB = cross([ustrip(uB[1]), ustrip(uB[2]), ustrip(uB[3])], [ustrip(uSeg[1]),ustrip(uSeg[2]),ustrip(uSeg[3])])

        uk = [0;0;1]
        dotA = dot(crossA, uk)
        dotB = dot(crossB, uk)

        return abs(1-abs(dotA) + 1-abs(dotB)) < ustrip(tol)
    end # isSegmentTangent

    function angleCorrect(angle::Radian)
        return (ustrip(angle) + 2*pi)%(2*pi) * 1.0u"rad"
    end
    function angleCorrect(angle)
        return (angle + 2*pi)%(2*pi)
    end

end #Geometry2D


