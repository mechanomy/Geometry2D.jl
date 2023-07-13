# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# """
# Defines a 2D Point and provides various functions on it.
# The key concept is that a Point is a discrete location in the 2D plane, located by physical units defined in that plane.
# This means that two Points cannot be added together, but a single Point can be added to via a unitful vector.
# This separation of concepts is a little cumbersome but makes very clear what is being modeled.
# """

import Base.+, Base.-, Base.*, Base./, Base.isapprox
import LinearAlgebra.norm 

export Point, Delta, UnitVector2D, distance, angle, angler, angled, length, normalize, norm, isapprox

"""
A point on the cartesian plane, measured in `x` and `y` from the plane's origin.
"""
struct Point
  x::Unitful.Length
  y::Unitful.Length
end
@kwdispatch Point()

"""
    Point(;x::Unitful.Length, y::Unitful.Length) 
Keyword constructor for a point on the cartesian plane, measured in `x` and `y` from the plane's origin.
"""
@kwmethod Point(;x::Unitful.Length, y::Unitful.Length) = Point(x,y)
# @kwmethod Point(refrenceFrame; x::Unitful.Length, y::Unitful.Length) = Point(x,y) # maybe introduce multiple reference frames...later

"""
A difference between two points on the cartesian plane, measured in `dx` and `dy` from the plane's origin.
This is introduced as a separate type to avoid using Vector{}s with inexplicit length.
"""
struct Delta
  dx::Unitful.Length
  dy::Unitful.Length
end
@kwdispatch Delta()
@kwmethod Delta(;dx::Unitful.Length, dy::Unitful.Length) = Delta(dx,dy)


# could use StaticArrays.jl to define fixed-length arrays, but this way I can enforce unit length at construction...
"""A `UnitVector2D` type is unitless, expressing only relative magnitude. It has fields `x` and `y`."""
struct UnitVector2D
  x::Real
  y::Real

  """
      UnitVector2D(x::Real, y::Real)
  Default constructor enforcing unit length.
  """
  UnitVector2D(x::Real, y::Real) = new(x/norm([x,y]), y/norm([x,y]))
end

"""
    UnitVector2D(dl::Delta)
Constructs a UnitVector2D in the direction of `dl`.
"""
UnitVector2D(dl::Delta) = normalize(dl)

@kwdispatch UnitVector2D()
"""
    UnitVector2D(; x::Real, y::Real)
Keyword constructor.
"""
@kwmethod UnitVector2D(; x::Real, y::Real) = UnitVector2D(x,y)


# It doesn't make sense to Plot deltas by themselves, rather they are a line between Points but since Delta does not record the originating Points this can't be drawn by a Recipe
# Similarly for UnitVectors which also need to attach to a Point for plotting
"""
A plot recipe for plotting Points under Plots.jl.
```
p = Point( 3mm,4mm )
plot(p)
```
"""
@recipe function plotRecipe(point::Point)
  # seriestype := :path # turns seriestype := :path into plotattributes[:seriestype] = :path, forcing that attribute value
  # th = LinRange(0,2*π, 100)
  # # x = ustrip(axisUnit, circle.center.x) .+ ustrip(axisUnit, circle.radius) .* cos.(th) #w/o UnitfulRecipes
  # # y = ustrip(axisUnit, circle.center.y) .+ ustrip(axisUnit, circle.radius) .* sin.(th)
  # x = circle.center.x .+ circle.radius .* cos.(th) #wit UnitfulRecipes, applies a unit label to the axes
  # y = circle.center.y .+ circle.radius .* sin.(th)
  # point.x, point.y #return the data
  markershape --> :circle
  [ustrip(point.x)], [ustrip(point.y)] #return the data
end

"""
    (-)(a::Point, b::Point) :: Delta
Finds the Delta between Points `a` and `b`.
"""
function (-)(a::Point, b::Point) :: Delta
  return Delta(dx=a.x-b.x, dy=a.y-b.y)
end

"""
    (+)(p::Point, d::Delta) :: Point
Adds a `d` Delta to Point `p`.
"""
function (+)(p::Point, d::Delta) :: Point
  return Point(x=p.x+d.dx, y=p.y+d.dy)
end

"""
    (-)(p::Point, d::Delta) :: Point
Subtracts a Delta `d` from the Point `p`.
"""
function (-)(p::Point, d::Delta) :: Point
  return Point(x=p.x-d.dx, y=p.y-d.dy)
end

""" 
    (*)(p::Point, f::Real) :: Point
Multiplies `p` by the given factor `f`.
"""
function (*)(p::Point, f::Real) :: Point
  return Point(x=p.x*f, y=p.y*f)
end

"""
    (/)(p::Point, f::Real) :: Point
Divides `p` by the given factor `f`.
"""
function (/)(p::Point, f::Real) :: Point
  return Point(x=p.x/f, y=p.y/f)
end

"""
    (/)(d::Delta, f::Real) :: Delta
Divides `d` by the given factor `f`.
"""
function (/)(d::Delta, f::Real) :: Delta
  return Delta(dx=d.dx/f, dy=d.dy/f)
  # return Delta(d.dx/f, d.dy/f)
end

""" 
    angle(d::Delta) :: Radian
Calculate the angle of Delta `d` relative to global x = horizontal.
"""
function angler(d::Delta) :: Radian
  # return angle(d) * 1.0u"rad" just calls itself, not the Real producing
  return atan(d.dy, d.dx) * 1.0u"rad"
end
function angled(d::Delta) :: typeof(1.0u"°") #Given a 'd' since dispatch does not distinguish by return type, scuttling precompilation
  return rad2deg(atan(d.dy, d.dx)) * 1.0u"°" #this is atan2
end

""" 
    angle(d::Delta) :: Real
Calculate the angle of Delta `d` relative to global x = horizontal.
"""
function Base.angle(d::Delta) :: Real
  return atan(d.dy,d.dx) #this is atan2
end

"""
    distance(a::Point, b::Point ) :: Unitful.Length
Finds the straight-line distance between `a` and `b`.
(It is nonsensical to ask for the 'distance' of a [Delta](#Geometry2D.Delta), rather Deltas have norm().)
"""
function distance(a::Point, b::Point )::Unitful.Length
  return norm(a-b)
end

"""
    norm( pt::Point; p=2 ) :: Unitful.Length
Returns the `p`-norm of `pt`.
"""
function norm( pt::Point; p=2 ) :: Unitful.Length
  return norm( [pt.x, pt.y], p )
end

"""
    norm( d::Delta; p=2 ) :: Unitful.Length
Returns the `p`-norm of `d`.
"""
function norm( d::Delta; p=2 ) ::Unitful.Length
  return norm( [d.dx, d.dy], p )
end

"""
    norm( u::UnitVector2D; p=2 ) :: Real
Returns the `p`-norm of `u`.
"""
function norm( u::UnitVector2D; p=2 ) :: Real
  return norm( [u.x, u.y], p )
end

"""
    normalize( p::Point ) :: UnitVector2D
Return a [UnitVector2D](#Geometry2D.UnitVector2D) pointing toward Point `p`.
"""
function normalize( p::Point )::UnitVector2D 
  np = norm(p)
  return UnitVector2D(p.x/np, p.y/np) #units cancel
end

"""
    normalize( d::Delta ) :: UnitVector2D
Return a [UnitVector2D](#Geometry2D.UnitVector2D) for Delta `d`.
"""
function normalize( d::Delta )::UnitVector2D  #https://github.com/PainterQubits/Unitful.jl/issues/346
  nd = norm(d)
  return UnitVector2D(d.dx/nd, d.dy/nd) #units cancel
end


"""
    isapprox(p::Point, q::Point; atol=0, rtol=√eps()) :: Bool 
Approximately compare Points `p` and `q` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function isapprox(p::Point, q::Point; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(p.x), p.x), ustrip(unit(p.x), q.x), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
          isapprox( ustrip(unit(p.x), p.y), ustrip(unit(p.x), q.y), atol=atol, rtol=rtol)
end

"""
    isapprox(a::Delta, b::Delta; atol=0, rtol=√eps()) :: Bool
Approximately compare Deltas `a` and `b` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function isapprox(a::Delta, b::Delta; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(a.dx), a.dx), ustrip(unit(a.dx), b.dx), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
         isapprox( ustrip(unit(a.dx), a.dy), ustrip(unit(a.dx), b.dy), atol=atol, rtol=rtol)
end

"""
    isapprox(a::UnitVector2D, b::UnitVector2D; atol=0, rtol=√eps()) :: Bool 
Approximately compare UnitVector2Ds `a` and `b` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function isapprox(a::UnitVector2D, b::UnitVector2D; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(a.x), a.x), ustrip(unit(a.x), b.x), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
         isapprox( ustrip(unit(a.x), a.y), ustrip(unit(a.x), b.y), atol=atol, rtol=rtol)
end

