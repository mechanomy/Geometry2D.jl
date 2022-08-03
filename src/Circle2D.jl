# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Circle2D.jl is a member of Geometry2D.jl via the include()s listed there.

export Circle, pointOnCircle, radialVector, isSegmentMutuallyTangent, isSegmentPerpendicularToParallelVectors, circleArcLength, circumference, circleArea

using LinearAlgebra:cross, dot, norm

"""
A circle having a `center::Point` and a `radius::Unitful.Length`.
"""
struct Circle
  center::Point #[x,y] of the pulley center
  radius::Unitful.Length
end

"""
    Circle( x::Unitful.Length, y::Unitful.Length, r::Unitful.Length ) 
A circle having a center at `x::Unitful.Length` and `y::Unitful.Length` with `radius::Unitful.Length`.
"""
Circle( x::Unitful.Length, y::Unitful.Length, r::Unitful.Length ) = Circle(Geometry2D.Point(x,y), r)
@kwdispatch Circle()

"""
    Circle(; center::Point, radius::Unitful.Length )
A circle having a `center::Point` and a `radius::Unitful.Length`.
"""
@kwmethod Circle(; center::Point, radius::Unitful.Length ) = Circle(center, radius)


"""
    pointOnCircle( c::Circle, a::Angle ) :: Point
Returns the [`Point`](#Geometry2D.Point) on `c` at angle `a` measured from +x.
"""
function pointOnCircle( c::Circle, a::Angle ) :: Point
  return c.center + Delta(c.radius*cos(a), c.radius*sin(a))
end

"""
    radialVector( c::Circle, a::Angle ) :: Vector2D
Returns a [`Vector2D`](#Geometry2D.Vector2D) with origin at `c.center` and tip at angle `a` and `c.radius`.
"""
function radialVector( c::Circle, a::Angle ) :: Vector2D
  return Vector2D(origin=c.center, tip=pointOnCircle(c, a))
end

"""
    isSegmentMutuallyTangent(; cA::Circle, cB::Circle, thA::Radian, thB::Radian, tol::Number=1e-3) :: Bool
Given [`Circles`](#Geometry2D.Circle) `circleA` and `circleB`, tests whether the points on their edges at angles `thA` and `thB` define a line segment that is tangent to both circles.
`tol` is the tolerance on the tangency criterion.
"""
function isSegmentMutuallyTangent(; cA::Circle, cB::Circle, thA::Radian, thB::Radian, tol::Number=1e-3) :: Bool
  rvA = radialVector( cA, thA ) 
  rvB = radialVector( cB, thB ) 
  return isSegmentPerpendicularToParallelVectors( rvA, rvB, tol)
end

"""
    isSegmentPerpendicularToParallelVectors( vA::Vector2D, vB::Vector2D, tol::Number=1e-3) :: Bool
Tests whether a segment connecting the tips of `vA` and `vB` is perpendicular to both, which implies parallelity of `vA` and `vB`.
The calculation compares the direction of the cross products of `vA` and the tip-connecting segment, and `vB` and the segment, that these are within `tol` of each other.
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
    circleArcLength( radius::Unitful.Length, angle::Angle )
Compute the circlular arc length at `radius` over `angle`.
```
angle = 20u"°" 
radius = 5u"mm"
len = circleArcLength(angle, radius)
```
"""
function circleArcLength( radius::Unitful.Length, angle::Angle )
  return abs(uconvert(u"rad", angle)) * abs(radius)
  # return uconvert(u"m", Geometry2D.circleArcLength( p.pitch, calculateWrappedAngle(p)) ) #cancel m*rad
end

"""
    circleArcLength( circle::Circle, angle::Angle )
Compute the circlular arc length of `circle` over `angle`.
"""
function circleArcLength( circle::Circle, angle::Angle )
  return circleArcLength( circle.radius, angle )
end

"""
    circumference( r::Unitful.Length ) :: Unitful.Length
Calculate the circumeference of `circle`.
"""
function circumference( r::Unitful.Length ) :: Unitful.Length
  return circleArcLength(r, 2*π * u"rad" )
end

"""
    circumference( circle::Circle )
Calculate the circumeference of `circle`.
"""
function circumference( circle::Circle ) :: Unitful.Length
  return circleArcLength(circle, 2*π * u"rad" )
end

"""
    circleArea(r::Unitful.Length) :: Unitful.Area
Calculate the area of a circle with radius `r`.
"""
function circleArea(r::Unitful.Length) :: Unitful.Area
  return π*r^2
end
"""
    circleArea(c::Circle) :: Unitful.Area
Calculate the area of a circle with radius `r`.
"""
function circleArea(c::Circle) :: Unitful.Area
  return circleArea(c.radius)
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
  # axisUnit=u"mm"
  axisUnit=unit(circle.radius)
  x = ustrip(axisUnit, circle.center.x) .+ ustrip(axisUnit, circle.radius) .* cos.(th) #w/o UnitfulRecipes
  y = ustrip(axisUnit, circle.center.y) .+ ustrip(axisUnit, circle.radius) .* sin.(th)
  # x = circle.center.x .+ circle.radius .* cos.(th) #with UnitfulRecipes, applies a unit label to the axes
  # y = circle.center.y .+ circle.radius .* sin.(th) #...but doesn't apply the same scale to both axes, eg mm in x and inch in y
  x,y #return the data
end

