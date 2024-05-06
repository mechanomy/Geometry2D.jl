# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Circle2D.jl is a member of Geometry2D.jl via the include()s listed there.

export Circle, pointOnCircle, radialVector, isSegmentMutuallyTangent, isSegmentPerpendicularToParallelVectors, circleArcLength, circumference, circleArea

using LinearAlgebra:cross, dot, norm

"""
A circle having a `center::Point2D` and a `radius::Unitful.Length`.
"""
struct Circle
  center::Point2D #[x,y] of the pulley center
  radius::AbstractLength
end

"""
    Circle( x::Unitful.Length, y::Unitful.Length, r::Unitful.Length ) 
A circle having a center at `x::Unitful.Length` and `y::Unitful.Length` with `radius::Unitful.Length`.
"""
Circle( x::AbstractLength, y::AbstractLength, r::AbstractLength ) = Circle(Geometry2D.Point2D(x,y), r)

@kwdispatch Circle()
"""
    Circle(; center::Point2D, radius::Unitful.Length )
A circle having a `center::Point2D` and a `radius::Unitful.Length`.
"""
@kwmethod Circle(; center::Point2D, radius::AbstractLength ) = Circle(center, radius)
@testitem "Circle constructors" begin
  using UnitTypes
  p = Point2D(MilliMeter(1),Inch(2))
  r = CentiMeter(5)
  c = Circle(p, r) 
  @test c.center.x ≈ MilliMeter(1) && c.center.y ≈ MilliMeter(50.8)
  @test c.radius ≈ CentiMeter(5)
  @test typeof( Circle(center=p, radius=r) ) <: Circle
  @test typeof( Circle(MilliMeter(1),MilliMeter(2),MilliMeter(3)) ) <: Circle
end

"""
    pointOnCircle( c::Circle, a::Angle ) :: Point2D
Returns the [`Point2D`](#Geometry2D.Point2D) on `c` at angle `a` measured from +x.
"""
function pointOnCircle( c::Circle, a::AbstractAngle ) :: Point2D
  return c.center + Delta(c.radius*cos(a), c.radius*sin(a))
end
@testitem "pointOnCircle" begin
  using UnitTypes
  c = Circle(Point2D(Meter(0),Meter(0)), Meter(√2) )
  p = pointOnCircle(c, Degree(45))
  @test isapprox(p.x, Meter(1), atol=1e-3)
  @test isapprox(p.y, Meter(1), atol=1e-3)
end

"""
    radialVector( c::Circle, a::Angle ) :: Vector2D
Returns a [`Vector2D`](#Geometry2D.Vector2D) with origin at `c.center` and tip at angle `a` and `c.radius`.
"""
function radialVector( c::Circle, a::AbstractAngle ) :: Vector2D
  return Vector2D(origin=c.center, tip=pointOnCircle(c, a))
end
@testitem "radialVector" begin
  using UnitTypes
  c = Circle(Point2D(Meter(0),Meter(0)), Meter(√2) )
  v = radialVector(c, Degree(45))
  @test isapprox(v.tip.x, Meter(1), atol=1e-3)
  @test isapprox(v.tip.y, Meter(1), atol=1e-3)
  @test isapprox(v.origin.x, Meter(0), atol=1e-3)
end


"""
    isSegmentMutuallyTangent(; cA::Circle, cB::Circle, thA::Radian, thB::Radian, tol::Number=1e-3) :: Bool
Given [`Circles`](#Geometry2D.Circle) `circleA` and `circleB`, tests whether the points on their edges at angles `thA` and `thB` define a line segment that is tangent to both circles.
`tol` is the tolerance on the tangency criterion.
"""
function isSegmentMutuallyTangent(; cA::Circle, cB::Circle, thA::AbstractAngle, thB::AbstractAngle, tol::Number=1e-3) :: Bool
  rvA = radialVector( cA, thA ) 
  rvB = radialVector( cB, thB ) 
  return isSegmentPerpendicularToParallelVectors( rvA, rvB, tol)
end
@testitem "isSegmentMutuallyTangent" begin
  using UnitTypes
  ca = Circle(Point2D(Meter(0),Meter(0)), Meter(1))
  aa = Degree(90)
  cb = Circle(Point2D(Meter(10),Meter(0)), Meter(1))
  ab = Degree(90)
  @test isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cb, thB=ab)

  cc = Circle(Point2D(Meter(10),Meter(0)), Meter(1))
  ac = Degree(-90)
  @test !isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cc, thB=ac)

  c0 = Circle(Point2D(Meter(0),Meter(0)), Meter(1)) #null case
  a0 = Degree(90)
  @test_throws ArgumentError isSegmentMutuallyTangent(cA=ca, thA=aa, cB=c0, thB=a0)
end

"""
    isSegmentPerpendicularToParallelVectors( vA::Vector2D, vB::Vector2D, tol::Number=1e-3) :: Bool
Tests whether a segment connecting the tips of `vA` and `vB` is perpendicular to both, which implies parallelity of `vA` and `vB`.
The calculation compares the direction of the cross products of `vA` and the tip-connecting segment, and `vB` and the segment, that these products are within `tol` of each other.
"""
function isSegmentPerpendicularToParallelVectors( vA::Vector2D, vB::Vector2D, tol::Number=1e-3)
  if vA ≈ vB
    throw( ArgumentError("isSegmentPerpendicularToParllelVectors: The given points on cirlces are identical, A=[$vA] vs B=[$vB]"))
  end
  dA = delta( vA )
  dB = delta( vB )
  uA = normalize(dA) 
  uB = normalize(dB)

  pA = vA.origin + dA
  pB = vB.origin + dB
  dSeg = pA-pB
  uSeg = normalize(dSeg)
  crossA = cross([uA.x, uA.y, 0], [uSeg.x,uSeg.y, 0])
  crossB = cross([uB.x, uB.y, 0], [uSeg.x,uSeg.y, 0])

  uk = [0;0;1]
  dotA = dot(crossA, uk)
  dotB = dot(crossB, uk)
  res = abs(1-abs(dotA) + 1-abs(dotB))
  return res < tol
end 
@testitem "isSegmentMutuallyTangent" begin
  using UnitTypes
  ca = Circle(Point2D(Meter(0),Meter(0)), Meter(1))
  va = radialVector(ca, Degree(90))
  cb = Circle(Point2D(Meter(10),Meter(0)), Meter(1))
  vb = radialVector(cb, Degree(90))
  @test isSegmentPerpendicularToParallelVectors(va, vb)
  vc = radialVector(cb, Degree(91))
  @test !isSegmentPerpendicularToParallelVectors(va, vc, 1e-5)
end

"""
    circleArcLength( radius::Unitful.Length, angle::Angle )
Compute the circlular arc length at `radius` over `angle`.
```
angle = 20u"°" 
radius = 5u"mm"
len = circleArcLength(angle, radius)
```
"""
function circleArcLength( radius::AbstractLength, angle::AbstractAngle )
  # return abs(Radian(angle).value) * abs(radius) # UnitTypes does not have abs() yet
  T = typeof(radius)
  return T(abs(Radian(angle).value) * abs(radius.value))
end

"""
    circleArcLength( circle::Circle, angle::AbstractAngle )
Compute the circlular arc length of `circle` over `angle`.
"""
function circleArcLength( circle::Circle, angle::AbstractAngle )
  return circleArcLength( circle.radius, angle )
end
@testitem "circleArcLength calculation" begin
  using UnitTypes
  @test circleArcLength(Meter(1), Radian(1)) ≈ Meter(1)
  @test circleArcLength(Meter(1), Radian(-1)) ≈ Meter(1)
  @test circleArcLength(Meter(-1), Radian(-1)) ≈ Meter(1)

  ca = Circle(Point2D(Meter(0),Meter(0)), Meter(1))
  @test circleArcLength(ca, Radian(1)) ≈ Meter(1)
end

"""
    circumference( r::AbstractLength ) :: AbstractLength
Calculate the circumeference of `circle`.
"""
function circumference( r::AbstractLength ) :: AbstractLength
  return circleArcLength(r, Radian(2*π) )
end
"""
    circumference( circle::Circle )
Calculate the circumeference of `circle`.
"""
function circumference( circle::Circle ) :: AbstractLength
  return circleArcLength(circle, Radian(2*π) )
end
@testitem "circumference" begin
  using UnitTypes
  @test circumference(Meter(1)) ≈ Meter(π*2.0)
  @test circumference(Meter(-1)) ≈ Meter(π*2.0)
  @test circumference(Circle(Meter(3),Meter(2),Meter(1))) ≈ Meter(π*2.0)
end

"""
    circleArea(r::AbstractLength) :: AbstractArea
Calculate the area of a circle with radius `r`.
"""
function circleArea(r::AbstractLength) :: AbstractArea
  # return π*r^2
  return π*r*r
end
"""
    circleArea(c::Circle) :: AbstractArea
Calculate the area of a circle with radius `r`.
"""
function circleArea(c::Circle) :: AbstractArea
  return circleArea(c.radius)
end
@testitem "circleArea" begin
  using UnitTypes
  @test circleArea(Meter(1)) ≈ π*Meter2(1^2)
  @test circleArea(Meter(-1)) ≈ π*Meter2(1^2)
  @test circleArea(Circle(Meter(3),Meter(2),Meter(1))) ≈ π*Meter2(1^2)
end

# """
# A plot recipe for plotting Circles under Plots.jl.
# ```
# c = Circle( 3mm,4mm, 5mm )
# plot(c) #plot(c, linecolor=:red, ...kwArgs... )
# ```
# """
# @recipe function plotRecipe(circle::Circle) 
#   seriestype := :path # turns seriestype := :path into plotattributes[:seriestype] = :path, forcing that attribute value
  
#   th = LinRange(0,2*π, 100)
#   x = toBaseFloat(circle.center.x) .+ toBaseFloat(circle.radius) .* cos.(th) #w/o UnitfulRecipes
#   y = toBaseFloat(circle.center.y) .+ toBaseFloat(circle.radius) .* sin.(th)
#   x,y #return the data
# end
# # re testing plots, https://discourse.julialang.org/t/how-to-test-plot-recipes/2648/4
# @testitem "Circle plotRecipe" begin
#   using UnitTypes
#   using VisualRegressionTests
#   using Plots
#   gr()
#   function fun(fname)
#     c = Circle(MilliMeter(1),MilliMeter(2),MilliMeter(3))
#     p = plot(c, reuse=false)

#     c = Circle(MilliMeter(1),MilliMeter(2),MilliMeter(4))
#     p = plot!(c, linecolor=:red, xlabel="x", ylabel="y")

#     savefig(p, fname)
#   end
#   # fun("test/VisualRegressionTests/circle2D.png") # generate image first time
#   @visualtest fun "test/VisualRegressionTests/circle2D.png" true 0.2
# end

# # struct CircleSegment <: Geometry2D.Circle
# #   center::Point2D #[x,y] of the pulley center
# #   radius::AbstractLength
# #   start::DimensionfulAngles.Angle # start -> stop defines the direction of the arc, whether its the small or large segment of the circle
# #   stop::DimensionfulAngles.Angle
# # end
# # CircleSegment( c::Geometry2D.Circle, start::DimensionfulAngles.Angle, stop::DimensionfulAngles.Angle) = CircleSegment(c.center, c.radius, start, stop)
# # CircleSegment(radius::AbstractLength, start::Geometry2D.Point2D, stop::Geometry2D.Point2D) 

