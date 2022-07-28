# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



# Circle2D.jl is a member of Geometry2D.jl via the include()s listed there.

using LinearAlgebra:cross, dot, norm

"""A circle has a `center` and a `radius`"""
struct Circle
  center::Point #[x,y] of the pulley center
  radius::Unitful.Length
end
Circle( x::Unitful.Length, y::Unitful.Length, r::Unitful.Length ) = Circle(Geometry2D.Point(x,y), r)
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

"""
`isSegmentPerpendicularToParallelVectors( vA::Vector2D, vB::Vector2D, tol::Number=1e-3)::Bool`
Tests whether a segment connecting the tips of `a` and `b` is perpendicular to both, which also implies parallelity of `a` and `b`.
The calculation compares the direction of the cross products of `a` and the tip-connecting segment, and `b` and the segment, that these are within `tol` of each other.
"""
function isSegmentPerpendicularToParallelVectors( vA::Vector2D, vB::Vector2D, tol::Number=1e-3)
  if vA ≈ vB
    throw( ArgumentError("isSegmentTangent: The given points on cirlces are too close, A=[$vA] vs B=[$vB]"))
  end
  dA = delta( vA )
  dB = delta( vB )
  uA = UnitVector2D(dA) #this could be normalize() to remove UnitVector2D..
  uB = UnitVector2D(dB)

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

  # return uconvert(u"m", Geometry2D.circleArcLength( p.pitch, calculateWrappedAngle(p)) ) #cancel m*rad
end

function circleArcLength( circle::Circle, angle::Angle )
  return circleArcLength( circle.radius, angle )
end

function circumference( circle::Circle )
  return circleArcLength(circle, 2*π * u"rad" )
end

"""
A plot recipe for plotting Circles under Plots.jl.
```
c = Circle( 3mm,4mm, 5mm )
plot(c) #plot(c, linecolor=:red, ...kwArgs... )
```
"""
@recipe function plotRecipe(circle::Circle) 
  seriestype := :path # turns seriestype := :path into plotattributes[:seriestype] = :path, forcing that attribute value
  
  th = LinRange(0,2*π, 100)
  # x = ustrip(axisUnit, circle.center.x) .+ ustrip(axisUnit, circle.radius) .* cos.(th) #w/o UnitfulRecipes
  # y = ustrip(axisUnit, circle.center.y) .+ ustrip(axisUnit, circle.radius) .* sin.(th)
  x = circle.center.x .+ circle.radius .* cos.(th) #with UnitfulRecipes, applies a unit label to the axes
  y = circle.center.y .+ circle.radius .* sin.(th)
  x,y #return the data
end


# function circleArea(r::Unitful.Length) :: Unitful.Area
#   return π*r^2
# end
# function cylinderVolume(; r::Unitful.Length, L::Unitful.Length) :: Unitful.Volume
#   return circleArea(r) * L
# end


function testCircle2D()
  @testset "Circle constructors" begin
    p = Point(1u"mm",2u"inch")
    r = 5mm
    c = Circle(p, r) 
    @test c.center.x == 1u"mm" && c.center.y == 50.8u"mm" 
    @test c.radius == 5u"mm"
    @test typeof( Circle(center=p, radius=r) ) <: Circle
    @test typeof( Circle(1mm,2mm,3mm) ) <: Circle
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

  # re testing plots, https://discourse.julialang.org/t/how-to-test-plot-recipes/2648/4
  @testset "Circle plotRecipe" begin
    c = Circle(1mm,2mm,3mm)
    p = plot(c, reuse=false)
    c = Circle(1mm,2mm,4mm)
    p = plot!(c, linecolor=:red, xlabel="x", ylabel="y")
    display(p) #produces a correct gks qt plot window

    @test true
  end

end #testCircle()



