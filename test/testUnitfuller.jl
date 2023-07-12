
@testset "angleWrap" begin
  @test angleWrap(-7u"rad") ≈ 2*π-7
  @test angleWrap(-1u"rad") ≈ 2*π-1
  @test angleWrap(1u"rad") ≈ 1
  @test angleWrap(7u"rad") ≈ 7-2*π

  @test angleWrap(-7) ≈ 2*π-7
  @test angleWrap(-1) ≈ 2*π-1
  @test angleWrap(1) ≈ 1
  @test angleWrap(7) ≈ 7-2*π
end
