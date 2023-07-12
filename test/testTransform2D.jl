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
  p = Point(1u"m", 0u"m")
  r = Rz(p, 90u"°")
  @test r.x≈0u"m" && r.y≈1u"m"

  r = Rz(p, -90u"°")
  @test r.x≈0u"m" && r.y≈-1u"m"
end

@testset "Translation" begin
  p = Point(1u"m", 1u"m")
  t = Tx(p, 1u"mm")
  t = Ty(t, 1u"mm")
  @test t.x == 1001u"mm" && t.y == 1001u"mm"
end

