
@testset "Circle constructors" begin
  p = Point(1u"mm",2u"inch")
  r = 5mm
  c = Circle(p, r) 
  @test c.center.x == 1u"mm" && c.center.y == 50.8u"mm" 
  @test c.radius == 5u"mm"
  @test typeof( Circle(center=p, radius=r) ) <: Circle
  @test typeof( Circle(1mm,2mm,3mm) ) <: Circle
end

@testset "Circle isSegmentTangent" begin
  ca = Circle(Point(0m,0m), 1m)
  aa = 90°
  cb = Circle(Point(10m,0m), 1m)
  ab = 90°
  @test isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cb, thB=ab)

  cc = Circle(Point(10m,0m), 1m)
  ac = -90°
  @test !isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cc, thB=ac)

  c0 = Circle(Point(0m,0m), 1m) #null case
  a0 = 90°
  @test_throws ArgumentError isSegmentMutuallyTangent(cA=ca, thA=aa, cB=c0, thB=a0)
end

@testset "circleArcLength calculation" begin
  a = 1rad
  r = 1m
  @test circleArcLength(r, a) == 1m
  @test circleArcLength(r, -a) == 1m
  @test circleArcLength(-r, -a) == 1m

  ca = Circle(Point(0m,0m), r)
  @test circleArcLength(ca, a) == 1m
end

@testset "circumference" begin
  @test circumference(1m) == π*2.0m
  @test circumference(-1m) == π*2.0m
  @test circumference(Circle(3m,2m,1m)) == π*2.0m
end

@testset "circleArea" begin
  @test circleArea(1m) == π*(1.0m)^2
  @test circleArea(-1m) == π*(1.0m)^2
  @test circleArea(Circle(3m,2m,1m)) == π*(1.0m)^2
end

# re testing plots, https://discourse.julialang.org/t/how-to-test-plot-recipes/2648/4
@testset "Circle plotRecipe" begin
  c = Circle(1mm,2mm,3mm)
  p = plot(c, reuse=false)
  c = Circle(1mm,2mm,4mm)
  p = plot!(c, linecolor=:red, xlabel="x", ylabel="y")
  # display(p) #produces a correct gks qt plot window
  @test typeof(p) <: Plots.Plot{Plots.PyPlotBackend}
end




