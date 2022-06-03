

# Circle2D.jl is a member of Geometry2D.jl via the include()s listed there.


"""A circle has a `center` and a `radius`"""
struct Circle
  center::Point #[x,y] of the pulley center
  radius::Unitful.Length
end
@kwdispatch Circle()
@kwmethod Circle(; center::Point, radius::Unitful.Length ) = Circle(center, radius)


"""Returns the Point on `c` at angle `a`"""
function pointOnCircle( c::Circle, a::Angle ) :: Point
  return c.center + Delta(c.radius*cos(a), c.radius*sin(a))
end

function radialVector( c::Circle, a::Angle ) :: Vector
  return Vector(origin=c.center, tip=pointOnCircle(c, a))
end

"""Given Circles `circleA` and `circleB`, tests whether the points on their edge at circular angles `thA` and `thB` define a line segment tangent to both circles"""
function isSegmentMutuallyTangent( circleA::Circle, circleB::Circle, thA::Radian, thB::Radian, tol::Number=1e-3)
    #define rA and rB from 0,0
    rvA = radialVector( circleA, thA ) 
    rvB = radialVector( circleB, thB ) 
    if rvA ≈ rvB
      throw( ArgumentError("isSegmentTangent: The given points on cirlces are too close, A=[$rvA] vs B=[$rvB]"))
    end
    dA = delta( rvA )
    dB = delta( rvB )
    uA = UnitVector(dA)
    uB = UnitVector(dB)

    pA = circleA.center + dA
    pB = circleB.center + dB
    dSeg = pA-pB
    uSeg = normalize(dSeg)
    #cross product is a 3D concept but uA, uB, and uSeg lie in a plane, so add a z=0 to each:
    crossA = cross([ustrip(uA.x), ustrip(uA.y), 0], [ustrip(uSeg.x),ustrip(uSeg.y), 0])
    crossB = cross([ustrip(uB.x), ustrip(uB.y), 0], [ustrip(uSeg.x),ustrip(uSeg.y), 0])

    uk = [0;0;1]
    dotA = dot(crossA, uk)
    dotB = dot(crossB, uk)
    res = abs(1-abs(dotA) + 1-abs(dotB))
    return res < ustrip(tol)
end 


# using PyPlot
# function plotCircle( circ::Circle, col )
#   th = range(0,2*pi,length=100)
#   x = ustrip(circ.center.x) .+ ustrip(circ.radius).*cos.(th)
#   y = ustrip(circ.center.y) .+ ustrip(circ.radius).*sin.(th)
#   plot(x,y, color=col, alpha=0.5 )
# end

function testCircle2D()
  @testset "Circle constructors" begin
    p = Point(1u"mm",2u"inch")
    r = 5mm
    c = Circle(p, r) 
    @test c.center.x == 1u"mm" && c.center.y == 50.8u"mm" 
    @test c.radius == 5u"mm"
    @test typeof( Circle(center=p, radius=r) ) <: Circle
  end


  @testset "Circle isSegmentTangent" begin
    ca = Circle(Point(0m,0m), 1m)
    aa = 90°
    cb = Circle(Point(10m,0m), 1m)
    ab = 90°
    @test isSegmentMutuallyTangent(ca, cb, aa, ab)

    cc = Circle(Point(10m,0m), 1m)
    ac = -90°
    @test !isSegmentMutuallyTangent(ca, cc, aa, ac)

    c0 = Circle(Point(0m,0m), 1m) #null case
    a0 = 90°
    @test_throws ArgumentError isSegmentMutuallyTangent(ca, c0, aa, a0)
  end
end #testCircle()



