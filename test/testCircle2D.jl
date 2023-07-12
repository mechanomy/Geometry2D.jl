
@testset "Circle constructors" begin
  p = Point(1u"mm",2u"inch")
  r = 5u"mm"
  c = Circle(p, r) 
  @test c.center.x == 1u"mm" && c.center.y == 50.8u"mm" 
  @test c.radius == 5u"mm"
  @test typeof( Circle(center=p, radius=r) ) <: Circle
  @test typeof( Circle(1u"mm",2u"mm",3u"mm") ) <: Circle
end

@testset "Circle isSegmentTangent" begin
  ca = Circle(Point(0u"m",0u"m"), 1u"m")
  aa = 90u"°"
  cb = Circle(Point(10u"m",0u"m"), 1u"m")
  ab = 90u"°"
  @test isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cb, thB=ab)

  cc = Circle(Point(10u"m",0u"m"), 1u"m")
  ac = -90u"°"
  @test !isSegmentMutuallyTangent(cA=ca, thA=aa, cB=cc, thB=ac)

  c0 = Circle(Point(0u"m",0u"m"), 1u"m") #null case
  a0 = 90u"°"
  @test_throws ArgumentError isSegmentMutuallyTangent(cA=ca, thA=aa, cB=c0, thB=a0)
end

@testset "circleArcLength calculation" begin
  a = 1u"rad"
  r = 1u"m"
  @test circleArcLength(r, a) == 1u"m"
  @test circleArcLength(r, -a) == 1u"m"
  @test circleArcLength(-r, -a) == 1u"m"

  ca = Circle(Point(0u"m",0u"m"), r)
  @test circleArcLength(ca, a) == 1u"m"
end

@testset "circumference" begin
  @test circumference(1u"m") == π*2.0u"m"
  @test circumference(-1u"m") == π*2.0u"m"
  @test circumference(Circle(3u"m",2u"m",1u"m")) == π*2.0u"m"
end

@testset "circleArea" begin
  @test circleArea(1u"m") == π*(1.0u"m")^2
  @test circleArea(-1u"m") == π*(1.0u"m")^2
  @test circleArea(Circle(3u"m",2u"m",1u"m")) == π*(1.0u"m")^2
end

# re testing plots, https://discourse.julialang.org/t/how-to-test-plot-recipes/2648/4
@testset "Circle plotRecipe" begin
  c = Circle(1u"mm",2u"mm",3u"mm")
  p = plot(c, reuse=false)
  c = Circle(1u"mm",2u"mm",4u"mm")
  p = plot!(c, linecolor=:red, xlabel="x", ylabel="y")
  display(p) #produces a correct gks qt plot window
end




