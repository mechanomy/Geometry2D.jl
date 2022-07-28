@testset "Vector2D constructor" begin
  po = Point(1m, 1m)
  pt = Point(2m, 2m)
  @test typeof( Vector2D(po,pt) ) <: Vector2D #was the constructor successful? @test_nothrow hasn't shown up yet
  @test typeof( Vector2D(origin=po, tip=pt) ) <: Vector2D #was the constructor successful? @test_nothrow hasn't shown up yet
end

@testset "Vector2D angle calculation" begin
  po = Point(1m, 1m)
  pt = Point(2m, 2m)
  vot = Vector2D(po,pt)
  @test angle(vot) == 45°
  @test angle(Vector2D(po,pt)) == 45°

  pt = Point(2m, 0m)
  @test angle(Vector2D(po,pt)) == -45°
  # @test angle(Vector2D(po,pt)) == 315° =-45, do I want a circular or mod equals?

  pt = Point(0m, 0m)
  @test angle(Vector2D(po,pt)) == -135°
  # @test angle(Vector2D(po,pt)) == 225°
end
