@testset "Vector2D constructor" begin
  po = Point(1u"m", 1u"m")
  pt = Point(2u"m", 2u"m")
  @test typeof( Vector2D(po,pt) ) <: Vector2D #was the constructor successful? @test_nothrow hasn't shown up yet
  @test typeof( Vector2D(origin=po, tip=pt) ) <: Vector2D #was the constructor successful? @test_nothrow hasn't shown up yet
end

@testset "Vector2D angle calculation" begin
  po = Point(1u"m", 1u"m")
  pt = Point(2u"m", 2u"m")
  vot = Vector2D(po,pt)
  @test angled(vot) == 45u"°"
  @test angled(Vector2D(po,pt)) == 45u"°"

  pt = Point(2u"m", 0u"m")
  @test angled(Vector2D(po,pt)) == -45u"°"
  # @test angle(Vector2D(po,pt)) == 315° =-45, do I want a circular or mod equals?

  pt = Point(0u"m", 0u"m")
  @test angled(Vector2D(po,pt)) == -135u"°"
  # @test angle(Vector2D(po,pt)) == 225°
end
