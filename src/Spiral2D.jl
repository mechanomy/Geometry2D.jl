# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Spiral2D.jl is a member of Geometry2D.jl via the include()s listed there.

export Spiral, calcPitch, calcLength, isIncreasing, isDecreasing, isClockwise, isCounterClockwise, seriesPolar, seriesCartesian


# @deriveMeasure Radian(2*π) = Revolution(1) "rev"
# @deriveMeasure Meter(1)/Revolution(1) = Pitch(1) "m/rev" # can't do this yet
  # @ test typeof(Revolution(1)) <: AbstractRevolution
  # @ test typeof(Revolution(1)) <: AbstractAngle
  # @ test typeof(Meter(1)/Revolution(1)) <: AbstractPitch
@makeBaseMeasure Pitch MeterPerRev "m/rev" #defines AbstractPitch and MeterPerRev(): typeof(MeterPerRev(1)) <: AbstractPitch
@deriveMeasure MeterPerRev(1) = MeterPerRad(1/(2*π)) "m/rad"
@testitem "Unit definitions" begin
  using UnitTypes
  @test typeof(MeterPerRev(1)) <: AbstractPitch
  @test typeof(MeterPerRad(1)) <: AbstractPitch
  @test MeterPerRev(MeterPerRad(1)) ≈ MeterPerRev(2*π)
end

"""
Describes a spiral progressing from `a0`,`r0` to `a1`,`r1`. 
If `thickness` is not specified it is calculated such that each layer touches neighbors, a tightly wound spiral, if it is specified then an open spiral is modeled.
* `a0::AbstractAngle` -- start angle
* `a1::AbstractAngle` -- stop angle
* `r0::AbstractLength` -- start radius
* `r1::AbstractLength` -- stop radius
* `pitch::Abstract` -- pitch
"""
struct Spiral
  a0::AbstractAngle #start angle
  a1::AbstractAngle #stop angle
  r0::AbstractLength #starting radius
  r1::AbstractLength #stopping radius
  pitch::AbstractPitch #distance between consecutive layers. this is a field to be able to model tight and loose spirals
end

"""
    Spiral( a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength )
Create a Spiral, calculating the pitch from `a0`, `a1`, `r0`, and `r1`.
"""
Spiral( a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength ) = Spiral( a0, a1, r0, r1, calcPitch(a0,a1,r0,r1))

@kwdispatch Spiral()
"""
    Spiral(; a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength, pitch::AbstractPitch) = Spiral(a0, a1, r0, r1, pitch)
Keyword create a Spiral with `a0`, `a1`, `r0`, `r1`, and `pitch`.
"""
@kwmethod Spiral(; a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength, pitch::AbstractPitch) = Spiral(a0, a1, r0, r1, pitch)

"""
    Spiral( a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength )
Keyword create a Spiral, calculating the pitch from `a0`, `a1`, `r0`, and `r1`.
"""
@kwmethod Spiral(; a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength) = Spiral(a0, a1, r0, r1, calcPitch(a0,a1,r0,r1))
@testitem "Constructors" begin
  using UnitTypes
  @test isa(Spiral(Radian(1.1), Radian(2.2), Meter(3.3), Meter(3.4), MeterPerRev(1.1)), Spiral)
  @test isa(Spiral(a0=Radian(1.1), a1=Radian(2.2), r0=Meter(3.3), r1=Meter(3.4), pitch=MeterPerRev(1.1)), Spiral)
  @test isa(Spiral(a0=Radian(1.1), a1=Radian(2.2), r0=Meter(3.3), r1=Meter(3.4)), Spiral)
end

"""
    isCounterClockwise(s::Spiral) :: Bool
2D Spirals are 'counterclockwise' if of increasing angle, `a0` to `a1`.
"""
function isCounterClockwise(s::Spiral) :: Bool
  return s.a0 < s.a1
end

"""
    isClockwise(s::Spiral) :: Bool
Conversely, clockwise implies decreasing angle.
"""
function isClockwise(s::Spiral) :: Bool
  return s.a0 > s.a1
end
@testitem "is cw/ccw" begin
  using UnitTypes
  @test isCounterClockwise( Spiral(a0=Degree(1.1), a1=Degree(2.2), r0=Meter(3.3), r1=Meter(4.4)) ) == true
  @test isCounterClockwise( Spiral(a0=Degree(3.3), a1=Degree(2.2), r0=Meter(3.3), r1=Meter(4.4)) ) == false
  @test isClockwise( Spiral(a0=Degree(1.1), a1=Degree(2.2), r0=Meter(3.3), r1=Meter(4.4)) ) == false
  @test isClockwise( Spiral(a0=Degree(3.3), a1=Degree(2.2), r0=Meter(3.3), r1=Meter(4.4)) ) == true
end

"""
    isIncreasing(s::Spiral) :: Bool
Does the radius increase?
"""
function isIncreasing(s::Spiral) :: Bool
  return s.r0 < s.r1
end

"""
    isDecreasing(s::Spiral) :: Bool
Does the radius decrease"""
function isDecreasing(s::Spiral) :: Bool
  return s.r0 > s.r1
end
@testitem "isIncreasing/decreasing" begin
  using UnitTypes
  @test isIncreasing( Spiral(a0=Degree(1.1), a1=Degree(2.2), r0=Meter(3.3), r1=Meter(4.4)) ) == true
  @test isIncreasing( Spiral(a0=Degree(1.1), a1=Degree(2.2), r0=Meter(5.5), r1=Meter(4.4)) ) == false
  @test isDecreasing( Spiral(a0=Degree(1.1), a1=Degree(2.2), r0=Meter(5.5), r1=Meter(4.4)) ) == true
  @test isDecreasing( Spiral(a0=Degree(1.1), a1=Degree(2.2), r0=Meter(3.3), r1=Meter(4.4)) ) == false
end

"""
    calcPitch(a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength)
    calcPitch(; a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength)
    calcPitch(s::Spiral)
Calculate a spiral's pitch from (`r1`-`r0`)/(`a1`-`a0`).
The nominal units of Pitch defined to be [m/rev], but this will return Real if the arguments or Spiral are that, or a Pitch,m/rad,m/deg depending on __. 
"""
function calcPitch(a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength)
  return MeterPerRad(abs(Meter(r1-r0).value/Radian(a1-a0).value) * ( r0<r1 ? 1 : -1))
end
calcPitch(; a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength) = calcPitch(a0,a1,r0,r1)
calcPitch(s::Spiral) = calcPitch(s.a0, s.a1, s.r0, s.r1)

@testitem "calcPitch()" begin
  using UnitTypes
  @test calcPitch(Radian(1),Radian(2),Meter(3),Meter(4)) ≈ MeterPerRad(1)
  @test calcPitch(Radian(1),Radian(2),Meter(3),Meter(2)) ≈ MeterPerRad(-1)
end

"""
    calcLength(a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength)
    calcLength(;a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength)
    calcLength(s::Spiral)
  Length along the spiral, as if it were unrolled.
"""
function calcLength(a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength)
  if r0 < Meter(0)
    r0 = Meter(0)
  end
  if r1 <= Meter(0)
    return Meter(0)
  end

  if a0 == a1 && r0 != r1 # a straight, radial line
    return r1-r0
  end

  # A spiral's length is the angular difference * average radius, see https://www.engineeringtoolbox.com/spiral-length-d_2191.html 
  return  abs(Radian(a1-a0).value) * (r1+r0)/2
end
calcLength(;a0::AbstractAngle, a1::AbstractAngle, r0::AbstractLength, r1::AbstractLength) = calcLength(a0,a1,r0,r1)
calcLength(s::Spiral) = calcLength(s.a0, s.a1, s.r0, s.r1)
@testitem "calcLength()" begin
  using UnitTypes
  s2 = Spiral(a0=Degree(1.1), a1=Degree(1.1), r0=Meter(3.3), r1=Meter(4.4)) #straight line
  @test isapprox( calcLength(s2), Meter(1.1), atol=1e-3 )

  s3 = Spiral(a0=Degree(0), a1=Degree(360), r0=Meter(3.3), r1=Meter(3.3)) #a full circle
  @test isapprox( calcLength(s3), 2*π*Meter(3.3), atol=1e-3 )

  s4 = Spiral(a0=Degree(0), a1=Degree(360), r0=Meter(3.3), r1=Meter(4.4)) #length is the average circumference
  @test isapprox( calcLength(s4), π*Meter(3.3) + π*Meter(4.4), atol=1e-3 )

  s5 = Spiral(a0=Degree(0), a1=Degree(-360), r0=Meter(3.3), r1=Meter(4.4)) #ccw == cw lengths
  @test isapprox( calcLength(s4), calcLength(s5), atol=1e-3)
end

"""
    seriesPolar(s::Spiral, n::Int=1000)
    seriesPolar(; s::Spiral, n::Int=1000)
Spread `n` points over spiral `s`, returning a matrix with columns [`angles`,`radii`].
"""
function seriesPolar(s::Spiral, n::Int=1000)
  als = LinRange(s.a0, s.a1, n)
  rs = LinRange(s.r0, s.r1, n)
  return [collect(als) collect(rs)]
end
seriesPolar(; s::Spiral, n::Int=1000) = seriesPolar(s, n)

@testitem "seriesPolar()" begin # not a great test tbh
  using UnitTypes
  s1 = Spiral(a0=Degree(0), a1=Degree(45), r0=Meter(3.0), r1=Meter(4.0))
  asrs = seriesPolar(s1, 3)
  @test asrs[2,1] ≈ Degree(22.5)
  @test asrs[2,2] ≈ Meter(3.5)
end

"""
    seriesCartesian(s::Spiral, n::Int=1000)
    seriesCartesian(; s::Spiral, n::Int=1000)
Spread `n` points over spiral `s`, returning a matrix with columns [`xs` `ys`]"""
function seriesCartesian(s::Spiral, n::Int=1000)
  alrs = seriesPolar(s, n)
  return [ alrs[:,2].*cos.(alrs[:,1]) alrs[:,2].*sin.(alrs[:,1]) ]
end
seriesCartesian(; s::Spiral, n::Int=1000) = seriesCartesian(s,n)
@testitem "seriesCartesian()" begin 
  using UnitTypes
  s1 = Spiral(a0=Degree(0), a1=Degree(45), r0=Meter(3.0), r1=Meter(4.0))
  xys = seriesCartesian(s1, 3)
  @test isapprox(xys[2,1], Meter(3.23358), atol=1e-3)
  @test isapprox(xys[2,2], Meter(1.33939), atol=1e-3)
  @test isapprox(xys[3,1], Meter(√(4^2/2)), atol=1e-3)
end


