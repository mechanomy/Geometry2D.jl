  
@testset "legLeg2Hypotenuse" begin
  @test legLeg2Hypotenuse( 1u"m", 1u"m" ) ≈ sqrt(2)*u"m"
end

@testset "legHypotenuse2Leg" begin
  @test legHypotenuse2Leg( 1u"m", √2u"m" ) ≈ 1u"m"
  @test legHypotenuse2Leg( leg=1u"m", hyp=√2u"m" ) ≈ 1u"m"
end

@testset "angleOpposite2Adjacent" begin
  @test angleOpposite2Adjacent( (π/4)*u"rad", 1u"m" ) ≈ 1u"m"
end

@testset "angleAdjacent2Opposite" begin
  @test angleAdjacent2Opposite( (π/4)*u"rad", 1u"m" ) ≈ 1u"m"
end

@testset "lawOfCosines" begin
  @test lawOfCosines( 1u"m", 1u"m", 135u"°") ≈ legLeg2Hypotenuse( (1+√.5)*u"m", √.5u"m" ) 
end

@testset "lawOfSines" begin
  @test lawOfSines( 1u"m", 45u"°", 45u"°") ≈ 1u"m"
end
