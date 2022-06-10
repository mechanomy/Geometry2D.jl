# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


export Rz, Tx, Ty, UnitVector, ui, uj, uk, length, norm

"""A `UnitVector` type is unitless, expressing only relative magnitude. It has fields `x`, `y`, and `z`"""
struct UnitVector
  x::Real
  y::Real
  z::Real
  UnitVector(x::Real, y::Real, z::Real) = new(x/norm([x,y,z]), y/norm([x,y,z]), z/norm([x,y,z]))
end
UnitVector(vec::AbstractVector) = UnitVector(vec[1], vec[2], vec[3])
@kwdispatch UnitVector()
@kwmethod UnitVector(; x::Real, y::Real, z::Real) = UnitVector(x,y,z)




const ui = UnitVector([1,0,0])
const uj = UnitVector([0,1,0])
const uk = UnitVector([0,0,1])

function norm( uv::UnitVector; p=2 ) :: Real
  return norm([uv.x,uv.y,uv.z], p)
end



# import Base.+, Base.-, Base.*, Base./, Base.isapprox

"""
`(-)(a::Real, uv::UnitVector) :: UnitVector` Provides negation of UnitVectors
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

"""Approximately compare UnitVectors `a` to `b`"""
function isapprox(a::UnitVector, b::UnitVector; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox( ustrip(unit(a.x), a.x), ustrip(unit(a.x), b.x), atol=atol, rtol=rtol) &&  #compare all in the unit of p.x
         isapprox( ustrip(unit(a.x), a.y), ustrip(unit(a.x), b.y), atol=atol, rtol=rtol) && 
         isapprox( ustrip(unit(a.x), a.z), ustrip(unit(a.x), b.z), atol=atol, rtol=rtol)
end




"""Make a 2D Vector2D of <x>,<y>"""
function point2vec(p::Point)
    return [p.x; p.y; 1*unit(p.x)]
end

function vec2point(v::Vector{<:Unitful.Length})
  return Point(v[1], v[2])
end

"""Create a 2D rotation matrix effecting a rotation of <angle>"""
function Rz(angle::Real)
    return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
end
function Rz(angle::Angle)
    return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
end

function Rz(p::Point, a::Angle)
  return vec2point( Rz(a) * point2vec(p) )
end


"""Create a 2D translation matrix translating along local x by <a>"""
function Tx(a::Real) #homogeneous transformation matrices are multiplied and therefore should be unitless
    return [1 0 a; 0 1 0; 0 0 1]
end
function Tx(p::Point, d::Unitful.Length)
  return vec2point( Tx(ustrip.(unit(p.x),d)) * point2vec(p) )
end

"""Create a 2D translation matrix translating along local y by <b>"""
function Ty(b::Real)
    return [1 0 0; 0 1 b; 0 0 1]
end
function Ty(p::Point, d::Unitful.Length)
  return vec2point( Ty(ustrip.(unit(p.y),d)) * point2vec(p) )
end


function testTransform2D()
  @testset "UnitVector" begin
    ua = UnitVector(1,2,3)
    @test norm(ua) ≈ 1
    @test norm(-ua) ≈ 1
    ub = -ua
    @test ub.x == -ua.x

    @test isapprox(ua,ub) == false
    uc = UnitVector(1+1e-5,2,3)
    @test isapprox(ua,uc, rtol=1e-3) 

  end

  @testset "Rotation" begin
    p = Point(1m, 0m)
    r = Rz(p, 90°)
    @test r.x≈0m && r.y≈1m

    r = Rz(p, -90°)
    @test r.x≈0m && r.y≈-1m
  end

  @testset "Translation" begin
    p = Point(1m, 1m)
    t = Tx(p, 1mm)
    t = Ty(t, 1mm)
    @test t.x == 1001mm && t.y == 1001mm
  end

end
