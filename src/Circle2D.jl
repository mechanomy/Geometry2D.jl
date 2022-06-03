

# Circle2D.jl is a member of Geometry2D.jl via the include()s listed there.

using LinearAlgebra #for cross(), dot(), norm()

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

"""Returns a Vector2D with origin at `c.center` and tip at angle `a` and `c.radius`"""
function radialVector( c::Circle, a::Angle ) :: Vector2D
  return Vector2D(origin=c.center, tip=pointOnCircle(c, a))
end

"""Given Circles `circleA` and `circleB`, tests whether the points on their edge at circular angles `thA` and `thB` define a line segment tangent to both circles"""
function isSegmentMutuallyTangent(; cA::Circle, cB::Circle, thA::Radian, thB::Radian, tol::Number=1e-3)
  rvA = radialVector( cA, thA ) 
  rvB = radialVector( cB, thB ) 
  return isSegmentPerpendicularToParallelVectors( rvA, rvB, tol)
end

"""Tests whether a segment connecting the tips of `a` and `b` is perpendicular to both which also implies pallelity of `a` and `b`.
The calculation compares the direction of the cross products of `a` and the tip-connecting segment, and `b` and the segment, that these are within `tol` of each other.
"""
function isSegmentPerpendicularToParallelVectors( vA::Vector2D, vB::Vector2D, tol::Number=1e-3)
  if vA ≈ vB
    throw( ArgumentError("isSegmentTangent: The given points on cirlces are too close, A=[$vA] vs B=[$vB]"))
  end
  dA = delta( vA )
  dB = delta( vB )
  uA = UnitVector(dA)
  uB = UnitVector(dB)

  pA = vA.origin + dA
  pB = vB.origin + dB
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


"""
Compute a circlular arc length at `radius` through `angle`
```
angle = 20u"°" 
radius = 5u"mm"
len = circleArcLength(angle, radius)
```
"""
function circleArcLength( radius::Unitful.Length, angle::Angle )
    return abs(uconvert(u"rad", angle)) * radius
end
function circleArcLength( circle::Circle, angle::Angle )
  return circleArcLength( circle.radius, angle )
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
    @test isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cb, thB=ab)

    cc = Circle(Point(10m,0m), 1m)
    ac = -90°
    @test !isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cc, thB=ac)

    c0 = Circle(Point(0m,0m), 1m) #null case
    a0 = 90°
    @test_throws ArgumentError isSegmentMutuallyTangent(cA=ca, thA=aa, cB=c0, thB=a0)
  end

  @testset "circleArcLength calculation" begin
    a = 1rad
    r = 1m
    @test circleArcLength(r, a) == 1m
    @test circleArcLength(r, -a) == 1m

    ca = Circle(Point(0m,0m), r)
    @test circleArcLength(ca, a) == 1m
  end


end #testCircle()



