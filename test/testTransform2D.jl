@testset "UnitVector" begin
  ua = UnitVector(1,2,3)
  @test norm(ua) ≈ 1
  @test norm(-ua) ≈ 1
  ub = -ua
  @test ub.x == -ua.x

  @test isapprox(ua,ub) == false
  uc = UnitVector(1+1e-5,2,3)
  @test isapprox(ua,uc, rtol=1e-3) 

end

@testset "Rotation" begin
  p = Point(1m, 0m)
  r = Rz(p, 90°)
  @test r.x≈0m && r.y≈1m

  r = Rz(p, -90°)
  @test r.x≈0m && r.y≈-1m
end

@testset "Translation" begin
  p = Point(1m, 1m)
  t = Tx(p, 1mm)
  t = Ty(t, 1mm)
  @test t.x == 1001mm && t.y == 1001mm
end

