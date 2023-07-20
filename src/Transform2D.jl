# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#Transform2D contains various functions for 2D translations and rotations, implemented via homogeneous transformation matrices [eg]](https://en.wikipedia.org/wiki/Transformation_matrix#Examples_in_2_dimensions).

import LinearAlgebra.norm

export Rz, Tx, Ty, UnitVector, ui, uj, uk, length, norm

"""
A `UnitVector` type is unitless, expressing only relative magnitude. It has fields `x`, `y`, and `z`

$FIELDS

"""
struct UnitVector
  """Component in the x direction."""
  x::Real
  """Component in the y direction."""
  y::Real
  """Component in the z direction."""
  z::Real

  """
      UnitVector(x::Real, y::Real, z::Real)
  Specify the default constructor to ensure unit length.
  """
  UnitVector(x::Real, y::Real, z::Real) = new(x/norm([x,y,z]), y/norm([x,y,z]), z/norm([x,y,z]))
end

"""
    UnitVector(vec::AbstractVector)
Given some subtype of AbstractVector, return a UnitVector.
"""
UnitVector(vec::AbstractVector) = UnitVector(vec[1], vec[2], vec[3])
@kwdispatch UnitVector()

"""
    UnitVector(; x::Real, y::Real, z::Real)
A keyword constructor of UnitVectors.
"""
@kwmethod UnitVector(; x::Real, y::Real, z::Real) = UnitVector(x,y,z)


"""Convenience unit vector in the x direction."""
const ui = UnitVector(1,0,0)
"""Convenience unit vector in the y direction."""
const uj = UnitVector(0,1,0)
"""Convenience unit vector in the z direction."""
const uk = UnitVector(0,0,1)

"""
    norm( uv::UnitVector; p=2 ) :: Real
Returns the UnitVector's 2-norm, which _should_ always be 1.
"""
function norm( uv::UnitVector; p=2 ) :: Real
  return norm([uv.x,uv.y,uv.z], p)
end


# import Base.+, Base.-, Base.*, Base./, Base.isapprox

"""
    (-)(a::Real, uv::UnitVector) :: UnitVector 
Provides negation of UnitVectors.
"""
function (-)(uv::UnitVector) :: UnitVector
  return UnitVector(-uv.x, -uv.y, -uv.z)
end

# """
# `(*)(a::Real, uv::UnitVector) :: UnitVector`
# Multiplication: `a`*`uv`
# """
# function (*)(a::Real, uv::UnitVector) :: UnitVector
#   return UnitVector(a*uv.x, a*uv.y, a*uv.z)
# end

"""
    isapprox(a::UnitVector, b::UnitVector; atol=0, rtol=√eps()) :: Bool 
Approximately compare UnitVectors `a` to `b` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function Base.isapprox(a::UnitVector, b::UnitVector; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(a.x), a.x), ustrip(unit(a.x), b.x), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
         isapprox( ustrip(unit(a.x), a.y), ustrip(unit(a.x), b.y), atol=atol, rtol=rtol) && 
         isapprox( ustrip(unit(a.x), a.z), ustrip(unit(a.x), b.z), atol=atol, rtol=rtol)
end

"""
    toVector( uv::UnitVector ) :: AbstractVector
Convert `uv` to a Base.Vector.
"""
function toVector( uv::UnitVector ) :: AbstractVector
  return [uv.x, uv.y, uv.z]
end


"""
    point2hvec(p::Point)
Convert `p` into a 1-terminated Vector for multiplication with some homogeneous transformation matrix.
"""
function point2hvec(p::Point) #:: Vector{Quantity{Float64, 𝐋, FreeUnits{(m,), 𝐋, nothing}}} (alias for Array{Quantity{Float64, 𝐋, Unitful.FreeUnits{(m,), 𝐋, nothing}}, 1})
    return [p.x; p.y; 1*unit(p.x)]
end

"""
    hvec2point(v::Vector{<:Unitful.Length}) :: Point
Convert a 1-terminated vector back into a Point.
"""
function hvec2point(v::Vector{<:Unitful.Length}) :: Point
  return Point(v[1], v[2])
end

"""
    Rz(angle::Real)
Create a 2D rotation matrix effecting a rotation of `angle`.
Homogeneous transformation matrices are multiplicative and therefore should be unitless.
"""
function Rz(angle::Real)
    return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
end

"""
    Rz(angle::Angle)
Create a 2D rotation matrix effecting a rotation of `angle`.
Homogeneous transformation matrices are multiplicative and therefore should be unitless.
"""
function Rz(angle::Angle)
    return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
end

"""
    Rz(p::Point, a::Angle)
Rotate `p` in the plane an angle `a`.
"""
function Rz(p::Point, a::Angle) :: Point
  return hvec2point( Rz(a) * point2hvec(p) )
end

"""
    Tx(a::Real)
Create a 2D translation matrix translating along local X an angle `a`.
Homogeneous transformation matrices are multiplicative and therefore should be unitless.
"""
function Tx(a::Real) #homogeneous transformation matrices are multiplied and therefore should be unitless
    return [1 0 a; 0 1 0; 0 0 1]
end

"""
    Tx(p::Point, d::Unitful.Length)
Translate `p` a distance of `d` in the X direction.
Homogeneous transformation matrices are multiplicative and therefore should be unitless.
"""
function Tx(p::Point, d::Unitful.Length)
  return hvec2point( Tx(ustrip.(unit(p.x),d)) * point2hvec(p) )
end


"""
    Ty(b::Real)
Create a 2D translation matrix translating along local Y by `b`.
Homogeneous transformation matrices are multiplicative and therefore should be unitless.
"""
function Ty(b::Real)
    return [1 0 0; 0 1 b; 0 0 1]
end

"""
    Ty(p::Point, d::Unitful.Length)
Translate `p` a distance of `d` in the X direction.
Homogeneous transformation matrices are multiplicative and therefore should be unitless.
"""
function Ty(p::Point, d::Unitful.Length)
  return hvec2point( Ty(ustrip.(unit(p.y),d)) * point2hvec(p) )
end

