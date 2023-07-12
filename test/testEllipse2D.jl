

# this works fine in isolation but fails when run with the other tests
# using Test
# using ArbNumerics #for elliptic_e below
# @testset "ellipticArcLength crashing" begin
#   a = 50
#   b = 20
#   angle = deg2rad(60)
#   phi = atan( a/b*tan(angle))
#   me = 1 - (a/b)^2
#   @test isapprox( abs(b*elliptic_e( ArbReal(phi), ArbReal(me) )), 46.2663, atol=1e-3)
# end

@testset "Ellipse2D" begin 
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
    @test isapprox(l, 1.2822u"inch", rtol=1e-3 )
  end

  @testset "ellipticArcLength test throws" begin
    @test_throws DomainError ellipticArcLength( 20, 50, deg2rad(10), deg2rad(60) )
    @test_throws DomainError ellipticArcLength( -20, 50, deg2rad(10), deg2rad(60) )
    @test_throws DomainError ellipticArcLength( 20, -50, deg2rad(10), deg2rad(60) )
    @test_throws DomainError ellipticArcLength( 50, 20, deg2rad(200) )
    @test_throws DomainError ellipticArcLength( 50, 20, deg2rad(-200) )
  end
end