# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



using ArbNumerics #for elliptic_e below; v 1.5 is segfaulting, punt for now https://github.com/JeffreySarnoff/ArbNumerics.jl/issues/68

export ellipticArcLength

"""
    ellipticArcLength(a::Number, b::Number, angle::Number ) :: Number
Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` through `angle`, measured from `a`, via elliptic integral:
L = b * elliptic_e( atan(a/b*tan(angle)), 1-a^2/b^2 )
"""
function ellipticArcLength(a::Number, b::Number, angle::Number ) :: Number
  # see: https://math.stackexchange.com/a/1123737/974011 

  if a < 0
    throw(DomainError(a, "major axis [$a] must be greater than 0"))
  end
  if b < 0
    throw(DomainError(b, "minor axis [$b] must be greater than 0"))
  end
  if a < b
    throw(DomainError(a, "major axis [$a] is smaller than minor axis [$b]"))
  end
  if pi/2 < angle
    throw(DomainError(angle, "angle[$angle] should be less than pi/2"))
  end
  if angle < -pi/2
    throw(DomainError(angle, "angle[$angle] should be greater than -pi/2"))
  end

  # 230712 - getting a segfault when using ArbReal:
  # println("a $a $(typeof(a))")
  # println("b $b $(typeof(b))")
  # println("angle $angle $(typeof(angle))")
  phi = atan( a/b*tan(angle))
  me = 1 - (a/b)^2
  # println("me $me $(typeof(me))")
  # println("ArbReal(me) $(ArbReal(me)) $(typeof(ArbReal(me)))")
  # println("phi $phi $(typeof(phi))")
  # println("ArbReal(phi) $(ArbReal(phi)) $(typeof(ArbReal(phi)))")
  # @show abs(b*elliptic_e( ArbFloat(phi), ArbFloat(me) ))
  # println("this line segfaults: x = elliptic_e( ArbReal(phi), ArbReal(me)")
  # @show x = elliptic_e( ArbReal(phi), ArbReal(me) )

  # return abs(b*elliptic_e( ArbReal(phi), ArbReal(me) ))
  # @show phi
  # @show me
  return abs(b*elliptic_e( ArbFloat(phi), ArbFloat(me) ))
end
@testitem "ellipticArcLength calculation from x-axis" begin
  @test true
  #negative or positive have same length
  n60 = ellipticArcLength( 50, 20, deg2rad(-60) ) 
  n10 = ellipticArcLength( 50, 20, deg2rad(-10) )
  p10 = ellipticArcLength( 50, 20, deg2rad( 10) )
  p60 = ellipticArcLength( 50, 20, deg2rad( 60) )
  @test n60 == p60
  @test n10 == p10
end

# """
#     ellipticArcLength(a::AbstractLength, b::AbstractLength, angle::Angle)
# Unitful version.
# Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` through `angle`, measured from major axis `a`, via elliptic integral:.
# L = b * elliptic_e( atan(a/b*tan(angle)), 1-a^2/b^2 )
# """
# function ellipticArcLength(a::AbstractLength, b::AbstractLength, angle::AbstractAngle)
#     return ellipticArcLength( ustrip(unit(a), a), ustrip(unit(a), b), ustrip(u"rad", angle)) * unit(a)
# end
# @testitem "ellipticArcLength UnitTypes" begin
#   using UnitTypes
#   a = Inch(3)
#   b = MilliMeter(10)
#   ang = Degree(10)
#   eal = ellipticArcLength(a,b,ang)
#   @test isapprox(eal, Inch(1.2822), rtol=1e-3 )
# end


# """
#     ellipticArcLength(a::Number, b::Number, start::Number, stop::Number)
# Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` between `start` and `stop` angles, as measured from the major axis `a`.
# """
# function ellipticArcLength(a::Number, b::Number, start::Number, stop::Number)
#   lStart = ellipticArcLength(a,b, start)
#   lStop = ellipticArcLength(a,b, stop)
#   return lStop - lStart
# end
# function ellipticArcLength(a::AbstractLength, b::AbstractLength, start::AbstractAngle, stop::AbstractAngle)
#   lStart = ellipticArcLength(a,b, start)
#   lStop = ellipticArcLength(a,b, stop)
#   return lStop - lStart
# end
# @testitem "ellipticArcLength between angles" begin
#   k5020 = 36.874554322338
#   k50020 = 99.072689284541
#   l5020 = ellipticArcLength( 50, 20, deg2rad(10), deg2rad(60) )
#   l50020 = ellipticArcLength( 500, 20, deg2rad(10), deg2rad(60) )
#   @test k5020 ≈ l5020
#   @test k50020 ≈ l50020
# end

# @testitem "ellipticArcLength test throws" begin
#   @test_throws DomainError ellipticArcLength( 20, 50, deg2rad(10), deg2rad(60) )
#   @test_throws DomainError ellipticArcLength( -20, 50, deg2rad(10), deg2rad(60) )
#   @test_throws DomainError ellipticArcLength( 20, -50, deg2rad(10), deg2rad(60) )
#   @test_throws DomainError ellipticArcLength( 50, 20, deg2rad(200) )
#   @test_throws DomainError ellipticArcLength( 50, 20, deg2rad(-200) )
# end
