
module Geometry2D
    using LinearAlgebra #for cross(), dot(), norm()
    using Unitful
    using PyPlot #can use matplotlib arguments directly
    using Printf
    using StaticArrays #for defined-length arrays: SVector{3,T}
    using QuadGK #for numerical integration of ellipseArcLength

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
    Convert the circular `angle` into an 'ellipse' angle for the ellipse described by `radiusX` and `radiusY` axis lengths
    """
    function circular2EllipseAngle(; angle::Angle, radiusX::Unitful.Length, radiusY::Unitful.Length)
        #cf https://math.stackexchange.com/questions/433094/how-to-determine-the-arc-length-of-ellipse
        return atan(radiusX/radiusY*tan(uconvert(u"rad",angle)))
    end

    """
    Compute an elliptical arc length from the `radiusX` axis towards the `radiusY` axis between `start` and `stop` angles as measured from the `radiusX` axis
    ```
    start = 10u"°"
    stop  = 20u"°"
    radiusX = 5u"mm"
    radiusY = 3u"mm"
    len = ellipseSectorLength(start=start, stop=stop, radiusX=radiusX, radiusY=radiusY, showConstruction=true)
    ```
    """
    function ellipseArcLength(; start::Angle=0u"°", stop::Angle, radiusX::Unitful.Length, radiusY::Unitful.Length, showConstruction=false)

        # https://docs.julialang.org/en/v1/base/base/#Core.DomainError
        if radiusX < 0u"mm"
            throw(DomainError(radiusX, "ellipseArcLength(): radiusX axis length [$radiusX] should be positive"))
        end
        if radiusY < 0u"mm"
            throw(DomainError(radiusY, "ellipseArcLength(): radiusY axis length [$radiusY] should be positive"))
        end
        # if stop < 0u"rad"
        #     throw(DomainError(stop, "ellipseArcLength(): stop angle [$stop] should be positive"))
        # end
        # if start < 0u"rad"
        #     throw(DomainError(start, "ellipseArcLength(): start angle [$start] should be positive"))
        # end

        #cf https://math.stackexchange.com/questions/433094/how-to-determine-the-arc-length-of-ellipse
        estart = circular2EllipseAngle(angle=start, radiusX=radiusX, radiusY=radiusY) #the ellipse start angle
        estop = circular2EllipseAngle(angle=stop, radiusX=radiusX, radiusY=radiusY) #the ellipse stop angle
        int,err = quadgk( t-> sqrt( (ustrip(u"mm",radiusX)*cos(t))^2 + (ustrip(u"mm",radiusY)*sin(t))^2 ), estart, estop, rtol=1e-8 ) #convert lengths to mm, integrate along the arc of the ellipse

        int *= 1.0u"mm" #reapply units
        if err > 1e-3
            println("ellipseSectorLength() had a large error term [$err], don't trust the length")
        end

        if showConstruction
            umajor = ustrip(u"mm", radiusX)
            uminor = ustrip(u"mm", radiusY)
            ustop = ustrip(u"rad", stop)
            ustart = ustrip(u"rad", start)
            fig = figure()

            #plot  givens
            th = LinRange(0, 2*pi, 500) 
            plot(umajor*cos.(th), umajor*sin.(th), "k:", label="major circle")
            plot(umajor.*[0,cos(ustart)], umajor.*[0,sin(ustart)], "go-", label=@sprintf("start[%3.3f°]", ustrip(u"°",start)))
            plot(umajor.*[0,cos(ustop)], umajor.*[0,sin(ustop)], "ro-", label=@sprintf("stop[%3.3f°]", ustrip(u"°",stop)))
            plot(umajor*cos.(th),uminor.*sin.(th), "b--", label="ellipse")

            th = LinRange(estart, estop, 100)
            plot(umajor*cos.(th), uminor*sin.(th), "c-", label=@sprintf("arc[%3.3fmm]", ustrip(u"mm", int)))

            legend()
            title("ellipseArcLength()")
            ax = gca()
            ax.set_aspect("equal")
            grid()

        end

        return uconvert(unit(radiusX), int) #return in given units
    end


end #Geometry2D

