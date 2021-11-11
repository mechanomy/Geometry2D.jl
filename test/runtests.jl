
using Test
using Unitful
using Utility

include("../src/Geometry2D.jl")

# test rationale:
# - Uniful conversions are correct
# - math operations correct...?
function testPoint()
  p = Geometry2D.Point(1u"mm",2u"inch")
  return p.x == 1e-3u"m" && p.y == 50.8u"mm"
end
function testCircle()
  p = Geometry2D.Point(1u"mm",2u"inch")
  c = Geometry2D.Circle(p, 5u"mm")
  return c.center.x == 1u"mm" && c.center.y == 50.8u"mm" && c.radius == 5u"mm"
end
function testVectorLengthAngle()
  vla = Geometry2D.vectorLengthAngle( 10u"mm", 10u"rad" )
  return abs(Geometry2D.length(vla) - 10u"mm") < 1e-3u"mm"
end

@testset "test Geometry2D.Point" begin
  @test testPoint()
  @test testCircle()
  @test testVectorLengthAngle()
end


function ellipticArcLength_singleAngle()
  n60 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(-60) ) 
  n10 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(-10) )
  p10 = Geometry2D.ellipticArcLength( 50, 20, deg2rad( 10) )
  p60 = Geometry2D.ellipticArcLength( 50, 20, deg2rad( 60) )
  return n60 == p60 && n10 == p10
end

function ellipticArcLength_doubleAngle()
  k5020 = 36.874554322338
  k50020 = 99.072689284541
  l5020 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(10), deg2rad(60) )
  l50020 = Geometry2D.ellipticArcLength( 500, 20, deg2rad(10), deg2rad(60) )
  # return abs(k5020 - l5020)<1e-3 && abs(k50020 - l50020)<1e-3
  # return Geometry2D.eqTol(k5020, l5020, 1e-8) && Geometry2D.eqTol(k50020, l50020, 1e-8)
  return Utility.eqTol( ustrip(k5020), ustrip(l5020), 1e-8) && Utility.eqTol(ustrip(k50020), ustrip(l50020), 1e-8)
end

function ellipticArcLength_ba()
  l5020 = Geometry2D.ellipticArcLength( 20, 50, deg2rad(10), deg2rad(60) )
end
function ellipticArcLength_nega()
  l5020 = Geometry2D.ellipticArcLength( -20, 50, deg2rad(10), deg2rad(60) )
end
function ellipticArcLength_negb()
  l5020 = Geometry2D.ellipticArcLength( 20, -50, deg2rad(10), deg2rad(60) )
end
function ellipticArcLength_200()
  l5020 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(200) )
end
function ellipticArcLength_n200()
  l5020 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(-200) )
end

@testset "ellipticArcLength" begin
  @test ellipticArcLength_singleAngle()
  @test ellipticArcLength_doubleAngle()
  @test_throws DomainError ellipticArcLength_ba()
  @test_throws DomainError ellipticArcLength_nega()
  @test_throws DomainError ellipticArcLength_negb()
  @test_throws DomainError ellipticArcLength_200()
  @test_throws DomainError ellipticArcLength_n200()
end


function testRotation()
  sq22 = sqrt(2)/2
  a = Geometry2D.Vec(1,0)
  rz = Geometry2D.Rz(deg2rad(45))
  a45 = rz *a
  ret = Utility.eqTol(sq22, a45[1]) && Utility.eqTol(sq22, a45[2])

   
  return ret
end
#function test unitful translation


@testset "2D rotation and translation matrices" begin
  @test testRotation()
end