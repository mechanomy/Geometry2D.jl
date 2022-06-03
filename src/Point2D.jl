# """
# Defines a 2D Point and provides various functions on it.
# The key concept is that a Point is a discrete location in the 2D plane, located by physical units defined in that plane.
# This means that two Points cannot be added together, but a single Point can be added to via a unitful vector.
# This separation of concepts is a little cumbersome but makes very clear what is being modeled.
# """

import Base.+, Base.-, Base.*, Base./, Base.isapprox
import LinearAlgebra.norm

export Point, Delta

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
function (*)(p::Point, f::Number) :: Point
  return Point(x=p.x*f, y=p.y*f)
end
"""Divides `p` by the given factor `f`"""
function (/)(p::Point, f::Number) :: Point
  return Point(x=p.x/f, y=p.y/f)
end

"""Divides `d` by the given factor `f`"""
function (/)(d::Delta, f::Number) :: Delta
  return Delta(dx=d.dx/f, dy=d.dy/f)
  # return Delta(d.dx/f, d.dy/f)
end

#can't divide a delta by units and get a Delta, only a unitless magnitude...
# function (/)(d::Delta, f::Unitful.Length) :: Delta
#   return Delta(dx=d.dx/f, dy=d.dy/f)
# end


"""Approximately compare Points `p` to `q`"""
function isapprox(p::Point, q::Point; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(p.x), p.x), ustrip(unit(p.x), q.x), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
          isapprox( ustrip(unit(p.x), p.y), ustrip(unit(p.x), q.y), atol=atol, rtol=rtol)
end

"""Finds the straight-line distance between `a` and `b`"""
function distance(a::Point, b::Point )::Unitful.Length
  return length(a-b)
end

# """Provide addition between Points `a` and `b`"""
# function addPointVector(p::Point2D.Point, v)
#   return Point2D.Point(p.x + v[1], p.y+v[2])
# end

# function subtractPoints(a::Point2D.Point, b::Point2D.Point)
#   return [a.x - b.x; a.y-b.y; 0*a.x] # assume the units of a
# end

# """Calculate the angle of the Delta from `a` to `b` relative to global x = horizontal"""
# function angleBetweenPoints(a::Point2D.Point, b::Point2D.Point)
#   return angle(a-b)
# end

"""Calculate the angle of Delta `d` relative to global x = horizontal"""
function angle(d::Delta)
  return atan(d.dy,d.dx) #this is atan2
end

# """Returns a 2D vector from the `origin` along `angle` from global reference axis 'x' with magnitude `length`."""
# function vectorLengthAngle(length::Unitful.Length, angle::Radian) :: Vector{Unitful.Length}
#   return length * [cos(angle); sin(angle); 0]
# end
# function normalize( vec ) #LinearAlgebra.normalize messes up the units..
#   return vec / norm(vec)
# end

"""Returns the 2-norm of `d`"""
function length( d::Delta; p=2 )
  return norm(d, p=p)
end

"""Returns the 2-norm of `d`"""
function norm( d::Delta; p=2 ) ::Unitful.Length
  return norm( [d.dx, d.dy], p )
end

"""Approximately compare Deltas `a` to `b`"""
function isapprox(a::Delta, b::Delta; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(a.dx), a.dx), ustrip(unit(a.dx), b.dx), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
         isapprox( ustrip(unit(a.dx), a.dy), ustrip(unit(a.dx), b.dy), atol=atol, rtol=rtol)
end



#could use StaticArrays.jl to define fixed-length arrays, but this way I can enforce unit length at construction...
"""A `UnitVector` type is unitless, expressing only relative magnitude"""
struct UnitVector
  x::Number
  y::Number
  #constructor with length check
end
UnitVector(dl::Delta) = normalize(dl)
@kwdispatch UnitVector()
@kwmethod UnitVector(; x::Number, y::Number) = UnitVector(x,y)

# function UnitVector(dl::Delta) :: UnitVector
#   u = normalize( dl )
#   return UnitVector(u.x, u.y)
# end

"""Return a UnitVector for Delta `d`"""
function normalize( d::Delta )::UnitVector  #I should create&use a UnitVector type here.  Again we want descriptivity in our libraries and tools..
  nd = norm(d)
  return UnitVector(d.dx/nd, d.dy/nd) #units cancel
end

"""Returns the `p`-norm length of `u`"""
function length( u::UnitVector; p=2 ) :: Number
  return norm(u, p=p)
end
"""Returns the `p`-norm of `u`"""
function norm( u::UnitVector; p=2 ) :: Number
  return norm( [u.x, u.y], p )
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
  end

  @testset "Point functions" begin
    pa = Point(x=1m,y=2m)
    pb = Point(x=3m,y=4m)
    @test distance( pa, pb) == sqrt(8)*m
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
    @test length(dl) ≈ sqrt(9^2+18^2)*m
    @test norm(dl) ≈ sqrt(9^2+18^2)*m

    ua = normalize(pa-pb)
    @test length(ua) ≈ 1
  end


end