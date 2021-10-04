
module Geometry2D
    using LinearAlgebra #for cross(), dot(), norm()
    using Unitful
    using PyPlot #can use matplotlib arguments directly
    using Printf
    using StaticArrays #for defined-length arrays: SVector{3,T}
    # using QuadGK #for numerical integration of ellipseArcLength
    using ArbNumerics

    # using BPlot

    @derived_dimension Radian dimension(u"rad")
    # @derived_dimension Degree dimension(2*pi)
    # @unit deg "deg" Degree 360/2*pi false
    Angle{T} = Union{Quantity{T,NoDims,typeof(u"rad")}, Quantity{T,NoDims,typeof(u"°")}} where T

    const UnitVector{T} = SVector{3,T}
    const ui = UnitVector([1,0,0])
    const uj = UnitVector([0,1,0])
    const uk = UnitVector([0,0,1])

    struct Point
        x::Unitful.Length
        y::Unitful.Length
    end

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
    function length( vec )
        return norm(vec)
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

    """
    Compute a circlular arc length at `radius` through `angle`
    ```
    angle = 20u"°" 
    radius = 5u"mm"
    len = circleArcLength(angle, radius)
    ```
    """
    function circleArcLength( angle::Angle, radius::Unitful.Length )
        return uconvert(u"rad", angle) * radius
    end

    """
    A more explicit trig function
    """
    function angleOpposite2Adjacent(angle::Angle, opposite::Unitful.Length)
        return opposite / tan(angle)
    end
    function angleAdjacent2Opposite(angle::Angle, adjacent::Unitful.Length)
        return adjacent * tan(angle)
    end
    """
    Finds the length of the unknown `legC` from `legA`, `legB`, and `angleAB` between them
    """
    function lawOfCosines(legA::Unitful.Length, legB::Unitful.Length, angleAB::Angle)
        return sqrt( legA^2 + legB^2 -2*legA*legB*cos(angleAB))
    end
    """
    For any triangle with legs A, B, C and angles AB, BC, CA, so that `legA` is the open side of `angleBC`, finds legB corresponding to `angleCA`
    """
    function lawOfSines(legA::Unitful.Length, angleBC::Angle, angleCA::Angle, showDiagram=false)
        if showDiagram
            fig2 = figure()

            abc = uconvert(u"rad", angleBC)
            aca = uconvert(u"rad", angleCA)
            aab = (pi - abc - aca)u"rad"
            angleAB = uconvert(u"°", aab)

            # legA = 1u"m"
            legB = legA * sin(aca)/sin(abc)
            legC = legA * sin(aab)/sin(abc)

            vCA = [0;0]u"m" #vertex of angleCA
            vAB = vCA + legA*[cos(aca); sin(aca)]
            vBC = vCA + legA*[cos(aca); sin(aca)] + legB*[cos(abc); -sin(abc)]

            plot([ustrip(vAB[1]), ustrip(vBC[1])], [ustrip(vAB[2]), ustrip(vBC[2])], "bo-", ls="-", c="b") #[a,b] to make vectors, [a b] makes matrix
            plot([ustrip(vCA[1]), ustrip(vBC[1])], [ustrip(vCA[2]), ustrip(vBC[2])], "co-", ls="-", c="c")
            plot([ustrip(vAB[1]), ustrip(vCA[1])], [ustrip(vAB[2]), ustrip(vCA[2])], "mo-", ls="-", c="m")
            avg = mean([vAB, vBC])
            txtB = @sprintf("%3.3fmm", ustrip(u"mm", legB))
            text(ustrip(avg[1]), ustrip(avg[2]), "B[$txtB]", color="b", backgroundcolor=(1,1,1,0.5), alpha=0.8)
            avg = mean([vBC, vCA])
            txtC = @sprintf("%3.3fmm", ustrip(u"mm", legC))
            text(ustrip(avg[1]), ustrip(avg[2]), "C[$txtC]", color="c", backgroundcolor=(1,1,1,0.5), alpha=0.8)
            avg = mean([vCA, vAB])
            txtA = @sprintf("%3.3fmm", ustrip(u"mm", legA))
            text(ustrip(avg[1]), ustrip(avg[2]), "A[$txtA]", color="m", backgroundcolor=(1,1,1,0.5), alpha=0.8)
            text(ustrip(vAB[1]),ustrip(vAB[2]),"AB[$(uconvert(u"°",angleAB))]", color="c")
            text(ustrip(vBC[1]),ustrip(vBC[2]),"BC[$(uconvert(u"°",angleBC))]", color="m")
            text(ustrip(vCA[1]),ustrip(vCA[2]),"CA[$(uconvert(u"°",angleCA))]", color="b")
            title("lawOfSines()")
            ax = gca()
            ax.set_aspect("equal")
            grid()
        end
        return legA * sin(angleCA)/sin(angleBC)
    end


    """
    Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` through `angle` via elliptic integral:
    L = b * elliptic_e( atan(a/b*tan(angle)), 1-a^2/b^2 )
    """
    function ellipticArcLength(a, b, angle )
        # see: https://math.stackexchange.com/a/1123737/974011 

        if a < 0
            throw(DomainError(a, "major axis [$a] must be greater than 0"))
        end
        if b < 0
            throw(DomainError(b, "minor axis [$b] must be greater than 0"))
        end
        if a < b
            throw(DomainError(a, "major axis [$a] is smaller than minor axis [$b]"))
        end
        if pi/2 < angle
            throw(DomainError(angle, "angle[$angle] should be less than pi/2"))
        end
        if angle < -pi/2
            throw(DomainError(angle, "angle[$angle] should be greater than -pi/2"))
        end

        phi = atan( a/b*tan(angle))
        m = 1 - (a/b)^2
        return abs(b*elliptic_e( ArbReal(phi), ArbReal(m) ))
    end
    """
    Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` between `star` and `stop`
    """
    function ellipticArcLength(a, b, start, stop)
        lStart = ellipticArcLength(a,b, start)
        lStop = ellipticArcLength(a,b, stop)
        return lStop - lStart
    end




end #Geometry2D

