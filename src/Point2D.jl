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
import LinearAlgebra.norm, LinearAlgebra.normalize

export Point, Delta, distance, angle, length

"""A point on the cartesian plane, measured in `x` and `y` from the plane's origin"""
struct Point
  x::Unitful.Length
  y::Unitful.Length
end
@kwdispatch Point()
@kwmethod Point(;x::Unitful.Length, y::Unitful.Length) = Point(x,y)
# @kwmethod Point(refrenceFrame; x::Unitful.Length, y::Unitful.Length) = Point(x,y) # maybe introduce multiple reference frames...later; looking at you CadQuery


"""A difference between two points on the cartesian plane, measured in `dx` and `dy` from the plane's origin.
This is introduced as a separate type to avoid using Vector{}s with undetermined lengths.
"""
struct Delta
  dx::Unitful.Length
  dy::Unitful.Length
end
@kwdispatch Delta()
@kwmethod Delta(;dx::Unitful.Length, dy::Unitful.Length) = Delta(dx,dy)

"""Finds the Delta between `a` and `b`"""
function (-)(a::Point, b::Point) :: Delta
  return Delta(dx=a.x-b.x, dy=a.y-b.y)
end

"""Adds a `d` Delta to Point `p`"""
function (+)(p::Point, d::Delta) :: Point
  return Point(x=p.x+d.dx, y=p.y+d.dy)
end

"""Subtracts a Delta `d` from the Point `p`"""
function (-)(p::Point, d::Delta) :: Point
  return Point(x=p.x-d.dx, y=p.y-d.dy)
end

"""Multiplies `p` by the given factor `f`"""
function (*)(p::Point, f::Real) :: Point
  return Point(x=p.x*f, y=p.y*f)
end
"""Divides `p` by the given factor `f`"""
function (/)(p::Point, f::Real) :: Point
  return Point(x=p.x/f, y=p.y/f)
end

"""Divides `d` by the given factor `f`"""
function (/)(d::Delta, f::Real) :: Delta
  return Delta(dx=d.dx/f, dy=d.dy/f)
  # return Delta(d.dx/f, d.dy/f)
end
#can't divide a delta by units and get a Delta, only a unitless magnitude...
# function (/)(d::Delta, f::Unitful.Length) :: Delta
#   return Delta(dx=d.dx/f, dy=d.dy/f)
# end


"""Finds the straight-line distance between `a` and `b`"""
function distance(a::Point, b::Point )::Unitful.Length
  return norm(a-b)
end

"""Calculate the angle of Delta `d` relative to global x = horizontal"""
function angle(d::Delta)
  return atan(d.dy,d.dx) #this is atan2
end

# """
# `Base.length( d::Delta; p=2 ) :: Unitful.Length`
# Returns the 2-norm of `d`"""
# function Base.length( d::Delta; p=2 ) :: Unitful.Length
#   return norm(d, p=p)
# end

"""
`norm( pt::Point; p=2 ) :: Unitful.Length`
Returns the `p`-norm of `pt`"""
function norm( pt::Point; p=2 ) :: Unitful.Length
  return norm( [pt.x, pt.y], p )
end

"""
`norm( d::Delta; p=2 ) :: Unitful.Length`
Returns the `p`-norm of `d`"""
function norm( d::Delta; p=2 ) ::Unitful.Length
  return norm( [d.dx, d.dy], p )
end

"""Approximately compare Points `p` to `q`"""
function isapprox(p::Point, q::Point; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(p.x), p.x), ustrip(unit(p.x), q.x), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
          isapprox( ustrip(unit(p.x), p.y), ustrip(unit(p.x), q.y), atol=atol, rtol=rtol)
end

"""Approximately compare Deltas `a` to `b`"""
function isapprox(a::Delta, b::Delta; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(a.dx), a.dx), ustrip(unit(a.dx), b.dx), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
         isapprox( ustrip(unit(a.dx), a.dy), ustrip(unit(a.dx), b.dy), atol=atol, rtol=rtol)
end



#I could use StaticArrays.jl to define fixed-length arrays, but this way I can enforce unit length at construction...
"""A `UnitVector2D` type is unitless, expressing only relative magnitude. It has fields `x` and `y`"""
struct UnitVector2D
  x::Real
  y::Real
  #constructor with length enforcement 
  UnitVector2D(x::Real, y::Real) = new(x/norm([x,y]), y/norm([x,y]))
end
UnitVector2D(dl::Delta) = normalize(dl)
@kwdispatch UnitVector2D()
@kwmethod UnitVector2D(; x::Real, y::Real) = UnitVector2D(x,y)

"""`normalize( p::Point )::UnitVector2D`
Return a UnitVector2D pointing toward Point `p`"""
function normalize( p::Point )::UnitVector2D 
  np = norm(p)
  return UnitVector2D(p.x/np, p.y/np) #units cancel
end

"""`normalize( d::Delta )::UnitVector2D`
Return a UnitVector2D for Delta `d`"""
function normalize( d::Delta )::UnitVector2D  #https://github.com/PainterQubits/Unitful.jl/issues/346
  nd = norm(d)
  return UnitVector2D(d.dx/nd, d.dy/nd) #units cancel
end

"""Returns the `p`-norm of `u`"""
function norm( u::UnitVector2D; p=2 ) :: Real
  return norm( [u.x, u.y], p )
end

"""Approximately compare Deltas `a` to `b`"""
function isapprox(a::UnitVector2D, b::UnitVector2D; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(a.x), a.x), ustrip(unit(a.x), b.x), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
         isapprox( ustrip(unit(a.x), a.y), ustrip(unit(a.x), b.y), atol=atol, rtol=rtol)
end

function testPoint2D()

  # test rationale:
  # - Uniful conversions are correct
  # - assignments correct
  @testset "Point constructor" begin
    p = Point(1u"mm",2u"inch")
    @test p.x == 1e-3u"m" && p.y == 50.8u"mm"

    p = Point(x=1m,y=2m)
    @test p.x == 1m && p.y == 2m
  end

  @testset "Point operators" begin
    pa = Point(x=1m,y=2m)
    d = Delta(dx=3m,dy=4m)
    pb = pa+d
    @test pb == Point(4m, 6m)
    pc = pa-d
    @test pc == Point(-2m, -2m)
    pd = pa*3
    @test pd == Point(3m, 6m)
    pe = pa/3
    @test pe ≈ Point( (1/3)*m, (2/3)*m )

    @test Point(x=1m,y=2m) ≈ Point(x=1m,y=2m+1e-8m)# √eps=1e-8 or so
    @test !(Point(x=1m,y=2m) ≈ Point(x=1m,y=2m+1e-7m)) 

    @test norm(pa) ≈ sqrt(5)*m
  end

  @testset "Point functions" begin
    pa = Point(x=1m,y=2m)
    pb = Point(x=3m,y=4m)
    @test distance( pa, pb) == sqrt(8)*m

    @test isapprox(pa,pb) == false

    ua = normalize(pa)
    @test ua.x ≈ 1/sqrt(5)
    @test ua.y ≈ 2/sqrt(5)
  end

  @testset "Delta operators" begin
    pa = Point(x=10m,y=20m)
    pb = Point(x=1m,y=2m)
    dl = pa-pb
    @test dl.dx == 9m && dl.dy == 18m 
  end

  @testset "Delta functions" begin
    pa = Point(x=10m,y=20m)
    pb = Point(x=1m,y=2m)
    dl = pa-pb
    @test norm(dl) ≈ sqrt(9^2+18^2)*m

    ua = normalize(pa-pb)
    @test norm(ua) ≈ 1
  end

  @testset "UnitVector2D" begin
    ua = UnitVector2D(1,2) #constructor enforces unit length
    @test norm(ua) ≈ 1 
    ub = UnitVector2D(x=-1, y=1) #constructor enforces unit length
    @test norm(ub) ≈ 1 

    @test isapprox(ua, ub) == false
    uc = UnitVector2D(1+1e-5,2) #constructor enforces unit length
    @test isapprox(ua, uc, rtol=1e-3) == true
  end


end