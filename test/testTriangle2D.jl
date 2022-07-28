  
@testset "legLeg2Hypotenuse" begin
  @test legLeg2Hypotenuse( 1m, 1m ) ≈ sqrt(2)*m
end

@testset "legHypotenuse2Leg" begin
  @test legHypotenuse2Leg( 1m, √2m ) ≈ 1m
end

@testset "angleOpposite2Adjacent" begin
  @test angleOpposite2Adjacent( (π/4)*rad, 1m ) ≈ 1m
end

@testset "angleAdjacent2Opposite" begin
  @test angleAdjacent2Opposite( (π/4)*rad, 1m ) ≈ 1m
end

@testset "lawOfCosines" begin
  @test lawOfCosines( 1m, 1m, 135°) ≈ legLeg2Hypotenuse( (1+√.5)*m, √.5m ) 
end

@testset "lawOfSines" begin
  @test lawOfSines( 1m, 45°, 45°) ≈ 1m
end
