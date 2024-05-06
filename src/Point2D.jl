# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# """
# Defines a 2D Point2D and provides various functions on it.
# The key concept is that a Point2D is a discrete location in the 2D plane, located by physical units defined in that plane.
# This means that two Point2Ds cannot be added together, but a single Point can be added to via a unitful vector.
# This separation of concepts is a little cumbersome but makes very clear what is being modeled.
# """

import LinearAlgebra.norm 
import Base.- # other operations don't need to be imported?

export Point2D, Delta, UnitVector2D, distance, angle, angleRadian, angleDegree, length, normalize, norm, isapprox

"""
  A point on the cartesian plane, measured in `x` and `y` from the plane's origin.
"""
struct Point2D
  x::AbstractLength
  y::AbstractLength
end
@kwdispatch Point2D()
"""
  Point2D(;x, y) 
  Keyword constructor for a point on the cartesian plane, measured in `x` and `y` from the plane's origin.
"""
@kwmethod Point2D(;x::AbstractLength, y::AbstractLength) = Point2D(x,y)
@testitem "Point2D constructor" begin
  using UnitTypes
  p = Point2D(MilliMeter(1), Inch(2))
  @test p.x ≈ Meter(1e-3) && p.y ≈ MilliMeter(50.8)
  
  p = Point2D(y=MilliMeter(1), x=Inch(2))
  @test p.y ≈ Meter(1e-3) && p.x ≈ MilliMeter(50.8)
end

"""
  A difference between two points on the cartesian plane, measured in `dx` and `dy` from the plane's origin.
  This is introduced as a separate type to avoid using Vector{}s with inexplicit length.
"""
struct Delta
  dx::AbstractLength
  dy::AbstractLength
end
@kwdispatch Delta()
"""
  Delta(;dx, dy) 
  Keyword constructor for a delta on the cartesian plane, measured in `dx` and `dy`.
"""
@kwmethod Delta(;dx::AbstractLength, dy::AbstractLength) = Delta(dx,dy)
@testitem "Delta constructor" begin
  using UnitTypes
  dab = Delta(Meter(3), Inch(2))
  @test dab.dx ≈ Meter(3) && dab.dy ≈ MilliMeter(50.8)

  dab = Delta(dx=Meter(3), dy=Inch(2))
  @test dab.dx ≈ Meter(3) && dab.dy ≈ MilliMeter(50.8)
end


"""
A `UnitVector2D` type is unitless, expressing only relative magnitude. It has fields `x` and `y`.
"""
struct UnitVector2D
  x::Real
  y::Real

  """
      UnitVector2D(x::Real, y::Real)
  Default constructor enforcing unit length.
  """
  UnitVector2D(x::Real, y::Real) = new(x/norm([x,y]), y/norm([x,y])) # enforce unit length at construction
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
@kwmethod UnitVector2D(; x::AbstractLength, y::AbstractLength) = UnitVector2D(toBaseFloat(x), toBaseFloat(y) ) 

@testitem "UnitVector2D constructors" begin
  using UnitTypes
  ua = UnitVector2D(1,1) 
  @test ua.x ≈ 1/(√2)
  @test ua.y ≈ 1/(√2)

  ua = UnitVector2D(x=-1, y=1)
  @test ua.x ≈ -1/(√2)

  ua = UnitVector2D(x=Meter(11), y=Meter(11))
  @test ua.x ≈ 1/(√2)

  ua = UnitVector2D(Delta(Meter(1),Meter(1)) )
  @test ua.x ≈ 1/(√2)
end

"""
  (-)(a::Point2D, b::Point2D) :: Delta
  Finds the Delta between Point2Ds `a` and `b`.
"""
function Base.:-(a::Point2D, b::Point2D) :: Delta
  return Delta(dx=a.x-b.x, dy=a.y-b.y)
end
"""
    (-)(p::Point2D, d::Delta) :: Point2D
Subtracts a Delta `d` from the Point2D `p`.
"""
function Base.:-(p::Point2D, d::Delta) :: Point2D
  return Point2D(x=p.x-d.dx, y=p.y-d.dy)
end
# Base.:-(d::Delta, p::Point2D) = Point2D(x=d.dx-p.x, y=d.dy-p.y ) # this doesn't make semantic sense

@testitem "subtract" begin
  using UnitTypes
  pa = Point2D(x=Meter(1),y=Meter(2))
  pb = Point2D(x=Meter(3),y=Meter(4))
  dl = pb-pa
  @test dl.dx ≈ Meter(2)
  @test dl.dy ≈ Meter(2)

  pc = pa-dl
  @test pc.x ≈ Meter(-1)
  @test pc.y ≈ Meter(0)

  # pc = dl-pa-dl
  # @test pc.x ≈ Meter(-1)
  # @test pc.y ≈ Meter(2)
  # @test_throws semant error?
end

"""
    (+)(p::Point2D, d::Delta) :: Point2D
Adds a `d` Delta to Point2D `p`.
"""
function Base.:+(p::Point2D, d::Delta) :: Point2D 
  return Point2D(x=p.x+d.dx, y=p.y+d.dy)
end
Base.:+(d::Delta, p::Point2D) = p+d

@testitem "add" begin
  using UnitTypes
  pa = Point2D(x=Meter(1),y=Meter(2))
  dl = Delta(dx=Meter(3),dy=Meter(4))
  pb = pa+dl
  @test pb.x ≈ Meter(4)
  @test pb.y ≈ Meter(6)

  pb = dl+pa
  @test pb.x ≈ Meter(4)
  @test pb.y ≈ Meter(6)
end


""" 
    (*)(p::Point2D, f::Real) :: Point2D
Multiplies `p` by the given factor `f`.
"""
function Base.:*(p::Point2D, f::Real) :: Point2D
  return Point2D(x=p.x*f, y=p.y*f)
end
Base.:*(f::Real, p::Point2D) = p*f

@testitem "multiply" begin
  using UnitTypes
  pa = Point2D(x=Meter(1),y=Meter(2))
  pb = pa*2
  @test pb.x ≈ Meter(2)
  @test pb.y ≈ Meter(4)

  pb = 2*pa
  @test pb.x ≈ Meter(2)
  @test pb.y ≈ Meter(4)
end


"""
    (/)(p::Point2D, f::Real) :: Point2D
Divides `p` by the given factor `f`.
"""
function Base.:/(p::Point2D, f::Real) :: Point2D
  return Point2D(x=p.x/f, y=p.y/f)
end

"""
    (/)(d::Delta, f::Real) :: Delta
Divides `d` by the given factor `f`.
"""
function Base.:/(d::Delta, f::Real) :: Delta
  return Delta(dx=d.dx/f, dy=d.dy/f)
end
@testitem "divide" begin
  using UnitTypes
  pa = Point2D(x=MilliMeter(1),y=MilliMeter(2))
  pb = pa/2
  @test pb.x ≈ MilliMeter(0.5)
  @test pb.y ≈ MilliMeter(1)

  dl = Point2D(MilliMeter(1),MilliMeter(2))
  dd = dl/2
  @test dd.x ≈ MilliMeter(0.5)
  @test dd.y ≈ MilliMeter(1)
end

""" 
    angle(d::Delta) :: Real
Calculate the angle of Delta `d` relative to global x = horizontal.
"""
function Base.angle(d::Delta) :: Real 
  return atan(d.dy.value,d.dx.value) #this is atan2
end
""" 
    angleRadian(d::Delta) :: Radian
Calculate the angle of Delta `d` relative to global x = horizontal.
"""
function angleRadian(d::Delta) :: Radian
  return Radian(atan(d.dy.value, d.dx.value))
end

""" 
    angleDegree(d::Delta) :: Degree
Calculate the angle of Delta `d` relative to global x = horizontal.
"""
function angleDegree(d::Delta) #Dispatch does not distinguish by return type, scuttling precompilation
  return Degree(Radian(atan(d.dy.value, d.dx.value))) #this is atan2
end
@testitem "angle" begin
  using UnitTypes
  dl = Delta(MilliMeter(1), MilliMeter(1))
  @test angle(dl) ≈ Radian(Degree(45)).value
  @test angleRadian(dl) ≈ Degree(45)
  @test angleDegree(dl) ≈ Degree(45)
end

"""
    distance(a::Point2D, b::Point2D )
Finds the straight-line distance between `a` and `b`.
(It is nonsensical to ask for the 'distance' of a [Delta](#Geometry.Delta), rather Deltas have norm().)
"""
function distance(a::Point2D, b::Point2D ) 
  return norm(a-b)
end
@testitem "distance" begin
  using UnitTypes
  pa = Point2D(x=Meter(1),y=Meter(2))
  pb = Point2D(x=Meter(3),y=Meter(4))
  @test distance( pa, pb) ≈ Meter(sqrt(8))
end

"""
    norm( pt::Point2D; p=2 )
Returns the `p`-norm of `pt`.
"""
function norm( pt::Point2D; p=2 )
  T = typeof(pt.x)
  return T(norm( [pt.x.value, pt.y.value], p ))
end

"""
    norm( d::Delta; p=2 )
Returns the `p`-norm of `d`
"""
function norm( d::Delta; p=2 )
  T = typeof(d.dx)
  return T(norm( [d.dx.value, d.dy.value], p ))
end
# function norm( u::UnitVector2D; p=2 ) :: Real
# this is redundant, UnitVector2D is defined to have unit norm..
#   return 1. norm( [u.x, u.y], p ) # this is redundant, UnitVector2D defined to have unit norm..
# end
@testitem "norm" begin
  using UnitTypes

  pa = Point2D(x=Meter(1),y=Meter(2))
  @test norm(pa) ≈ Meter(sqrt(5))

  pa = Point2D(x=Meter(10),y=Meter(20))
  pb = Point2D(x=Meter(1),y=Meter(2))
  dl = pa-pb
  @test norm(dl) ≈ Meter(sqrt(9^2+18^2))
end

"""
    normalize( p::Point2D ) :: UnitVector2D
Return a [UnitVector2D](#Geometry.UnitVector) pointing toward Point2D `p`.
"""
function normalize( p::Point2D )::UnitVector2D
  np = norm(p)
  return UnitVector2D(p.x.value/np.value, p.y.value/np.value) #units cancel...but UnitTypes doesn't know how to Meter/Meter=>Number...
end

"""
    normalize( d::Delta ) :: UnitVector2D
Return a [UnitVector2D](#Geometry.UnitVector) for Delta `d`.
"""
function normalize( d::Delta )::UnitVector2D 
  nd = norm(d)
  return UnitVector2D(d.dx.value/nd.value, d.dy.value/nd.value) 
end

@testitem "normalize" begin
  using UnitTypes

  pa = Point2D(x=Meter(1),y=Meter(2))
  ua = normalize(pa)
  @test ua.x ≈ 1/sqrt(5)
  @test ua.y ≈ 2/sqrt(5)

  dl = Delta(MilliMeter(2), MilliMeter(2))
  ua = normalize(dl)
  @test ua.x ≈ 1/(√2)
end

"""
    Base.isapprox(p::Point2D, q::Point2D; atol=0, rtol=√eps()) :: Bool 
Approximately compare Point2Ds `p` and `q` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function Base.isapprox(p::Point2D, q::Point2D; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( p.x, convert(typeof(p.x), q.x), atol=atol, rtol=rtol) &&  #make all comparisons in the unit of p.x...
          isapprox( p.y, convert(typeof(p.x), q.y), atol=atol, rtol=rtol)
end

"""
    Base.isapprox(a::Delta, b::Delta; atol=0, rtol=√eps()) :: Bool
Approximately compare Deltas `a` and `b` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function Base.isapprox(a::Delta, b::Delta; atol=0, rtol=√eps()) :: Bool 
  return  isapprox( a.dx, convert(typeof(a.dx),b.dx), atol=atol, rtol=rtol) &&
          isapprox( a.dy, convert(typeof(a.dx),b.dy), atol=atol, rtol=rtol)
end

"""
    Base.isapprox(a::UnitVector2D, b::UnitVector; atol=0, rtol=√eps()) :: Bool 
Approximately compare UnitVector2Ds `a` and `b` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function Base.isapprox(a::UnitVector2D, b::UnitVector2D; atol=0, rtol=√eps()) :: Bool 
  return isapprox( a.x, b.x, atol=atol, rtol=rtol) && isapprox( a.y, b.y, atol=atol, rtol=rtol) 
end

@testitem "isapprox" begin
  using UnitTypes
  @test isapprox( Point2D(MilliMeter(1), MilliMeter(2)), Point2D(MilliMeter(1.0001), MilliMeter(2)), atol=1e-3)
  @test isapprox( Delta(MilliMeter(1), MilliMeter(2)), Delta(MilliMeter(1.0001), MilliMeter(2)), atol=1e-3)
  @test isapprox( UnitVector2D(1,2), UnitVector2D(1.0001, 2), atol=1e-3)
end

# # It doesn't make sense to Plot deltas by themselves, rather they are a line between Point2Ds but since Delta does not record the originating Points this can't be drawn by a Recipe
# # Similarly for UnitVector2Ds which also need to attach to a Point2D for plotting
# """
# A plot recipe for plotting Point2Ds under Plots.jl.
# ```
# p = Point2D( 3mm,4mm )
# plot(p)
# ```
# """
# @recipe function plotRecipe(point::Point2D)
#   markershape --> :circle
#   # [point.x, point.y] #Polts.jl v1.34.2 includes UnitfulRecipes, so I can return unitful
#   [toBaseFloat(point.x)], [toBaseFloat(point.y)] #return meter for now...
# end
# @testitem "Point2D recipe" begin
#   using UnitTypes
#   using VisualRegressionTests # https://github.com/JuliaPlots/VisualRegressionTests.jl
#   using Plots
#   function fun(fname)
#     pt = Point2D(MilliMeter(1),MilliMeter(2))
#     p = plot(pt, reuse=false)
#     p = plot!( Point2D(MilliMeter(1),MilliMeter(3)), color=:red )
#     p = plot!( Point2D(MilliMeter(5),MilliMeter(3)), markersize=10)
#     p = plot!( Point2D(MilliMeter(3),MilliMeter(3)), markershape=:diamond)
#     # @show p
#     savefig(p, fname)
#     # display(p)
#   end
#   # @visualtest testfun refimg popup tol
#   @visualtest fun "test/VisualRegressionTests/threePoints.png" true 0.2
# end

