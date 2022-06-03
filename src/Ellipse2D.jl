  

using ArbNumerics #for elliptic_e below

"""
function ellipticArcLength(a::Number, b::Number, angle::Number )::Number
Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` through `angle` via elliptic integral:
L = b * elliptic_e( atan(a/b*tan(angle)), 1-a^2/b^2 )
"""
function ellipticArcLength(a::Number, b::Number, angle::Number )::Number
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

  phi = atan( a/b*tan(angle))
  m = 1 - (a/b)^2
  return abs(b*elliptic_e( ArbReal(phi), ArbReal(m) ))
end

function ellipticArcLength(a::Unitful.Length, b::Unitful.Length, angle::Angle)
    return ellipticArcLength( ustrip(unit(a), a), ustrip(unit(a), b), ustrip(u"rad", angle)) * unit(a)
end

"""
Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` between `star` and `stop`
"""
function ellipticArcLength(a::Number, b::Number, start::Number, stop::Number)
  lStart = ellipticArcLength(a,b, start)
  lStop = ellipticArcLength(a,b, stop)
  return lStop - lStart
end

function testEllipse2D()
@testset "ellipticArcLength calculation from x-axis" begin
  #negative or positive have same length
  n60 = ellipticArcLength( 50, 20, deg2rad(-60) ) 
  n10 = ellipticArcLength( 50, 20, deg2rad(-10) )
  p10 = ellipticArcLength( 50, 20, deg2rad( 10) )
  p60 = ellipticArcLength( 50, 20, deg2rad( 60) )
  @test n60 == p60
  @test n10 == p10
end

@testset "ellipticArcLength between angles" begin
  k5020 = 36.874554322338
  k50020 = 99.072689284541
  l5020 = ellipticArcLength( 50, 20, deg2rad(10), deg2rad(60) )
  l50020 = ellipticArcLength( 500, 20, deg2rad(10), deg2rad(60) )
  @test k5020 ≈ l5020
  @test k50020 ≈ l50020
end

@testset "ellipticArcLength Unitful conversions" begin
  a = 3u"inch"
  b = 10u"mm"
  ang = 10u"°"
  l = ellipticArcLength(a,b,ang)
  # @test l ≈ 1.2822u"inch"
  @test isapprox(l, 1.2822u"inch", rtol=1e-4 )
end

@testset "ellipticArcLength test throws" begin
  @test_throws DomainError ellipticArcLength( 20, 50, deg2rad(10), deg2rad(60) )
  @test_throws DomainError ellipticArcLength( -20, 50, deg2rad(10), deg2rad(60) )
  @test_throws DomainError ellipticArcLength( 20, -50, deg2rad(10), deg2rad(60) )
  @test_throws DomainError ellipticArcLength( 50, 20, deg2rad(200) )
  @test_throws DomainError ellipticArcLength( 50, 20, deg2rad(-200) )
end

end