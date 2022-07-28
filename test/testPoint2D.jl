

# test rationale:
# - Uniful conversions are correct
# - assignments correct

@testset "Point constructor" begin
  p = Point(1u"mm", 2u"inch")
  @test p.x == 1e-3u"m" && p.y == 50.8u"mm"

  p = Point(x=1m,y=2m)
  @test p.x == 1m && p.y == 2m
end

@testset "Delta constructor" begin
  dab = Delta(3m, 4m)
  @test dab.dx == 3m && dab.dy == 4m
  dab = Delta(dx=3m, dy=4m)
  @test dab.dx == 3m && dab.dy == 4m
end

@testset "UnitVector2D constructor" begin
  ua = UnitVector2D(1,2) #constructor enforces unit length
  @test norm(ua) ≈ 1 

  ub = UnitVector2D(x=-1, y=1) #constructor enforces unit length
  @test norm(ub) ≈ 1 
end

@testset "operators" begin
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
end

@testset "distance" begin
  pa = Point(x=1m,y=2m)
  pb = Point(x=3m,y=4m)
  @test distance( pa, pb) == sqrt(8)*m
end

@testset "angle" begin
  pa = Point(x=4m,y=6m)
  pb = Point(x=1m,y=2m)
  dl = pa-pb
  @test angle(dl) ≈ atan(4,3)
  @test angle(dl) ≈ 0.927295218u"rad"
  @test isapprox(angle(dl), 53.1301°, rtol=3) 
end

@testset "norm" begin
  pa = Point(x=1m,y=2m)
  @test norm(pa) ≈ sqrt(5)*m

  pa = Point(x=10m,y=20m)
  pb = Point(x=1m,y=2m)
  dl = pa-pb
  @test norm(dl) ≈ sqrt(9^2+18^2)*m

end

@testset "normalize" begin
  pa = Point(x=1m,y=2m)
  ua = normalize(pa)
  @test ua.x ≈ 1/sqrt(5)
  @test ua.y ≈ 2/sqrt(5)

  pa = Point(x=10m,y=20m)
  pb = Point(x=1m,y=2m)
  dl = pa-pb
  ua = normalize(dl)
  @test norm(ua) ≈ 1
end

@testset "isapprox" begin
  pa = Point(x=1m,y=2m)
  d = Delta(dx=3m,dy=4m)
  pb = pa+d
  @test isapprox(pa,pb) == false

  pe = pa/3
  @test pe ≈ Point( (1/3)*m, (2/3)*m )

  @test Point(x=1m,y=2m) ≈ Point(x=1m,y=2m+1e-8m)# √eps=1e-8 or so
  @test !(Point(x=1m,y=2m) ≈ Point(x=1m,y=2m+1e-7m)) 

  @test !(Delta(dx=1m, dy=2m) ≈ Delta(dx=1.1m, dy=2.1m))

  ua = UnitVector2D(1,2) #constructor enforces unit length
  @test norm(ua) ≈ 1 

  ub = UnitVector2D(x=-1, y=1) #constructor enforces unit length
  @test norm(ub) ≈ 1 

  @test isapprox(ua, ub) == false
  uc = UnitVector2D(1+1e-5,2) #constructor enforces unit length
  @test isapprox(ua, uc, rtol=1e-3) == true
end


@testset "Point recipe" begin
  pt = Point(1mm,2mm)
  p = plot(pt, reuse=false)
  p = plot!( Point(1mm,3mm), color=:red )
  p = plot!( Point(2mm,3mm), markersize=10)
  p = plot!( Point(3mm,3mm), markershape=:diamond)
  @test typeof(p) <: Plots.Plot{Plots.PyPlotBackend}
  # display(p)
end

