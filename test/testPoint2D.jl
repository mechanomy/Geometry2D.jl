

# test rationale:
# - Uniful conversions are correct
# - assignments correct

@testset "Point constructor" begin
  p = Point(1u"mm", 2u"inch")
  @test p.x == 1e-3u"m" && p.y == 50.8u"mm"

  p = Point(x=1u"m",y=2u"m")
  @test p.x == 1u"m" && p.y == 2u"m"
end

@testset "Delta constructor" begin
  dab = Delta(3u"m", 4u"m")
  @test dab.dx == 3u"m" && dab.dy == 4u"m"
  dab = Delta(dx=3u"m", dy=4u"m")
  @test dab.dx == 3u"m" && dab.dy == 4u"m"
end

@testset "UnitVector2D constructor" begin
  ua = UnitVector2D(1,2) #constructor enforces unit length
  @test norm(ua) ≈ 1 

  ub = UnitVector2D(x=-1, y=1) #constructor enforces unit length
  @test norm(ub) ≈ 1 
end

@testset "operators" begin
  pa = Point(x=1u"m",y=2u"m")

  d = Delta(dx=3u"m",dy=4u"m")

  pb = pa+d
  @test pb == Point(4u"m", 6u"m")
  pc = pa-d
  @test pc == Point(-2u"m", -2u"m")
  pd = pa*3
  @test pd == Point(3u"m", 6u"m")
  pe = pa/3
  @test pe ≈ Point( (1/3)*u"m", (2/3)*u"m" )
end

@testset "distance" begin
  pa = Point(x=1u"m",y=2u"m")
  pb = Point(x=3u"m",y=4u"m")
  @test distance( pa, pb) == sqrt(8)*u"m"
end

@testset "angle" begin
  pa = Point(x=4u"m",y=6u"m")
  pb = Point(x=1u"m",y=2u"m")
  dl = pa-pb
  @test angle(dl) ≈ atan(4,3)
  @test angle(dl) ≈ 0.927295218u"rad"
  @test isapprox(angled(dl), 53.1301u"°", rtol=3) 
end

@testset "norm" begin
  pa = Point(x=1u"m",y=2u"m")
  @test norm(pa) ≈ sqrt(5)*u"m"

  pa = Point(x=10u"m",y=20u"m")
  pb = Point(x=1u"m",y=2u"m")
  dl = pa-pb
  @test norm(dl) ≈ sqrt(9^2+18^2)*u"m"

end

@testset "normalize" begin
  pa = Point(x=1u"m",y=2u"m")
  ua = normalize(pa)
  @test ua.x ≈ 1/sqrt(5)
  @test ua.y ≈ 2/sqrt(5)

  pa = Point(x=10u"m",y=20u"m")
  pb = Point(x=1u"m",y=2u"m")
  dl = pa-pb
  ua = normalize(dl)
  @test norm(ua) ≈ 1
end

@testset "isapprox" begin
  pa = Point(x=1u"m",y=2u"m")
  d = Delta(dx=3u"m",dy=4u"m")
  pb = pa+d
  @test isapprox(pa,pb) == false

  pe = pa/3
  @test pe ≈ Point( (1/3)*u"m", (2/3)*u"m" )

  @test Point(x=1u"m",y=2u"m") ≈ Point(x=1u"m",y=2u"m"+1e-8u"m")# √eps=1e-8 or so
  @test !(Point(x=1u"m",y=2u"m") ≈ Point(x=1u"m",y=2u"m"+1e-7u"m")) 

  @test !(Delta(dx=1u"m", dy=2u"m") ≈ Delta(dx=1.1u"m", dy=2.1u"m"))

  ua = UnitVector2D(1,2) #constructor enforces unit length
  @test norm(ua) ≈ 1 

  ub = UnitVector2D(x=-1, y=1) #constructor enforces unit length
  @test norm(ub) ≈ 1 

  @test isapprox(ua, ub) == false
  uc = UnitVector2D(1+1e-5,2) #constructor enforces unit length
  @test isapprox(ua, uc, rtol=1e-3) == true
end


@testset "Point recipe" begin
  pt = Point(1u"mm",2u"mm")
  p = plot(pt, reuse=false)
  p = plot!( Point(1u"mm",3u"mm"), color=:red )
  p = plot!( Point(2u"mm",3u"mm"), markersize=10)
  p = plot!( Point(3u"mm",3u"mm"), markershape=:diamond)
  display(p)
end

