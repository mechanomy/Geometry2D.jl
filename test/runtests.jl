
using Utility
using Test
using Unitful, Unitful.DefaultSymbols

include("../src/Geometry2D.jl")

# test rationale:
# - Uniful conversions are correct
# - assignments correct
@testset "Point constructor" begin
  p = Geometry2D.Point2D.Point(1u"mm",2u"inch")
  @test p.x == 1e-3u"m" && p.y == 50.8u"mm"

  p = Geometry2D.Point2D.Point(x=1m,y=2m)
  @test p.x == 1m && p.y == 2m
end

@testset "Point operators" begin
  pa = Geometry2D.Point2D.Point(x=1m,y=2m)
  d = Geometry2D.Point2D.Delta(dx=3m,dy=4m)
  pb = pa+d
  @test pb == Geometry2D.Point2D.Point(4m, 6m)
  pc = pa-d
  @test pc == Geometry2D.Point2D.Point(-2m, -2m)
  pd = pa*3
  @test pd == Geometry2D.Point2D.Point(3m, 6m)
  pe = pa/3
  @test pe ≈ Geometry2D.Point2D.Point( (1/3)*m, (2/3)*m )

  @test Geometry2D.Point2D.Point(x=1m,y=2m) ≈ Geometry2D.Point2D.Point(x=1m,y=2m+1e-8m)# √eps=1e-8 or so
  @test !(Geometry2D.Point2D.Point(x=1m,y=2m) ≈ Geometry2D.Point2D.Point(x=1m,y=2m+1e-7m)) 
end

@testset "Point functions" begin
  pa = Geometry2D.Point2D.Point(x=1m,y=2m)
  pb = Geometry2D.Point2D.Point(x=3m,y=4m)
  @test Geometry2D.Point2D.distance( pa, pb) == sqrt(8)*m
end




@testset "Delta operators" begin
  pa = Geometry2D.Point2D.Point(x=10m,y=20m)
  pb = Geometry2D.Point2D.Point(x=1m,y=2m)
  dl = pa-pb
  @test dl.dx == 9m && dl.dy == 18m 
end

@testset "Delta functions" begin
  pa = Geometry2D.Point2D.Point(x=10m,y=20m)
  pb = Geometry2D.Point2D.Point(x=1m,y=2m)
  dl = pa-pb
  @test Geometry2D.Point2D.length(dl) ≈ sqrt(9^2+18^2)*m
  @test Geometry2D.Point2D.norm(dl) ≈ sqrt(9^2+18^2)*m
end

# @testset "Point length angle" 


# function testCircle()
#   p = Geometry2D.Point(1u"mm",2u"inch")
#   c = Geometry2D.Circle(p, 5u"mm")
#   return c.center.x == 1u"mm" && c.center.y == 50.8u"mm" && c.radius == 5u"mm"
# end
# function testVectorLengthAngle()
#   vla = Geometry2D.vectorLengthAngle( 10u"mm", 10u"rad" )
#   return abs(Geometry2D.length(vla) - 10u"mm") < 1e-3u"mm"
# end

# @testset "test Geometry2D.Point" begin
#   @test testCircle()
#   @test testVectorLengthAngle()
# end


# function ellipticArcLength_singleAngle()
#   n60 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(-60) ) 
#   n10 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(-10) )
#   p10 = Geometry2D.ellipticArcLength( 50, 20, deg2rad( 10) )
#   p60 = Geometry2D.ellipticArcLength( 50, 20, deg2rad( 60) )
#   return n60 == p60 && n10 == p10
# end

# function ellipticArcLength_doubleAngle()
#   k5020 = 36.874554322338
#   k50020 = 99.072689284541
#   l5020 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(10), deg2rad(60) )
#   l50020 = Geometry2D.ellipticArcLength( 500, 20, deg2rad(10), deg2rad(60) )
#   # return abs(k5020 - l5020)<1e-3 && abs(k50020 - l50020)<1e-3
#   # return Geometry2D.eqTol(k5020, l5020, 1e-8) && Geometry2D.eqTol(k50020, l50020, 1e-8)
#   return Utility.eqTol( ustrip(k5020), ustrip(l5020), 1e-8) && Utility.eqTol(ustrip(k50020), ustrip(l50020), 1e-8)
# end

# function ellipticArcLength_ba()
#   l5020 = Geometry2D.ellipticArcLength( 20, 50, deg2rad(10), deg2rad(60) )
# end
# function ellipticArcLength_nega()
#   l5020 = Geometry2D.ellipticArcLength( -20, 50, deg2rad(10), deg2rad(60) )
# end
# function ellipticArcLength_negb()
#   l5020 = Geometry2D.ellipticArcLength( 20, -50, deg2rad(10), deg2rad(60) )
# end
# function ellipticArcLength_200()
#   l5020 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(200) )
# end
# function ellipticArcLength_n200()
#   l5020 = Geometry2D.ellipticArcLength( 50, 20, deg2rad(-200) )
# end

# function ellipticArcLength_units()
#   a = 3u"inch"
#   b = 10u"mm"
#   ang = 10u"°"
#   l = Geometry2D.ellipticArcLength(a,b,ang)

#   return Utility.eqTol( l, 1.2822u"inch" )
# end

# @testset "ellipticArcLength" begin
#   @test ellipticArcLength_singleAngle()
#   @test ellipticArcLength_doubleAngle()

#   @test_throws DomainError ellipticArcLength_ba()
#   @test_throws DomainError ellipticArcLength_nega()
#   @test_throws DomainError ellipticArcLength_negb()
#   @test_throws DomainError ellipticArcLength_200()
#   @test_throws DomainError ellipticArcLength_n200()

#   @test ellipticArcLength_units()

# end


# function testRotation()
#   # rotate ux by 45deg = 0.707;0.707
#   sq22 = sqrt(2)/2
#   a = Geometry2D.Vec(1,0)
#   rz = Geometry2D.Rz(deg2rad(45))
#   a45 = rz *a
#   ret = Utility.eqTol(sq22, a45[1]) && Utility.eqTol(sq22, a45[2])
#   return ret
# end
# function testTranslation()
#   a = Geometry2D.Vec(1,0)
#   tx = Geometry2D.Tx(1)
#   ty = Geometry2D.Ty(1)
#   # ty = Ty(1)
#   res = tx * ty * a
#   return Utility.eqTol(res[1], 2) && Utility.eqTol(res[2], 1)
# end
# @testset "2D rotation and translation matrices" begin
#   @test testRotation()
#   @test testTranslation()
# end


# function test_line()
#   a = Geometry2D.Point(0,0)
#   l = Geometry2D.line(a, )
# end
# @testset "line construct" begin
#   @test test_line()

# end