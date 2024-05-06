# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#Various convenient and explicit Trigonometric relations

#Are structs needed? How many primitives are needed and why?
# abstract type AbstractTriangle end
# struct Triangle <: AbstractTriangle
#   pa::Point
#   pb::Point
#   pc::Point
# end
# struct RightTriangle <: AbstractTriangle
#   pa::Point
#   pb::Point
#   pc::Point
#   RightTriangle() assert right angle
# end

export legLeg2Hypotenuse, legHypotenuse2Leg, angleOpposite2Adjacent, angleAdjacent2Opposite, lawOfCosines, lawOfSines

"""
    legLeg2Hypotenuse( a::Unitful.Length, b::Unitful.Length ) :: Unitful.Length
    legLeg2Hypotenuse(; a::Unitful.Length, b::Unitful.Length ) :: Unitful.Length
For a right triangle, find the length of the hypotenuse from the shorter legs `a` and `b`.
"""
function legLeg2Hypotenuse( a::AbstractLength, b::AbstractLength) :: AbstractLength 
  T = typeof(a)
  # return T(sqrt( a*a + b*b ))  # waiting for sqrt to push in UnitTypes
  return T( sqrt(toBaseFloat(a)^2 + toBaseFloat(b)^2))
end
legLeg2Hypotenuse(; a::AbstractLength, b::AbstractLength) = legLeg2Hypotenuse( a, b )
@testitem "legLeg2Hypotenuse" begin
  using UnitTypes
  @test legLeg2Hypotenuse( Meter(1), Meter(1) ) ≈ Meter(√2)
  @test legLeg2Hypotenuse( a=Meter(1), b=Meter(1) ) ≈ Meter(√2)
end


"""
    legHypotenuse2Leg( leg::Unitful.Length, hyp::Unitful.Length  ) :: Unitful.Length
    legHypotenuse2Leg(; leg::Unitful.Length, hyp::Unitful.Length  ) :: Unitful.Length
For a right triangle, find the length of the third leg from hypotenuse `hyp` and `leg`.
"""
function legHypotenuse2Leg( leg::AbstractLength, hyp::AbstractLength) :: AbstractLength 
  if hyp < leg
    throw( ArgumentError("leg[$leg] should be < than hyp[$hyp]") )
  end
  T = typeof(leg)
  # return T(sqrt( hyp*hyp - leg*leg ))
  return T(sqrt( toBaseFloat(hyp)^2 - toBaseFloat(leg)^2 ))
end
legHypotenuse2Leg(; leg::AbstractLength, hyp::AbstractLength) = legHypotenuse2Leg( leg, hyp )
@testitem "legHypotenuse2Leg" begin
  using UnitTypes
  @test isapprox(legHypotenuse2Leg( Meter(1), Meter(√2) ), Meter(1), rtol=1e-3)
  @test isapprox(legHypotenuse2Leg( leg=Meter(1), hyp=Meter(√2) ), Meter(1), rtol=1e-3)
end

"""
    angleOpposite2Adjacent(angle::Angle, opposite::Unitful.Length) :: Unitful.Length
    angleOpposite2Adjacent(; angle::Angle, opposite::Unitful.Length) :: Unitful.Length
For a right triangle, find the length of the 'adjacent' leg, given `angle` and `opposite`.
"""
function angleOpposite2Adjacent(angle::AbstractAngle, opposite::AbstractLength) :: AbstractLength 
  T = typeof(opposite)
  return T(opposite / tan(angle))
end
angleOpposite2Adjacent(; angle::AbstractAngle, opposite::AbstractLength) = angleOpposite2Adjacent( angle, opposite )
@testitem "angleOpposite2Adjacent" begin
  using UnitTypes
  @test isapprox(angleOpposite2Adjacent( Radian(π/4), Meter(1) ), Meter(1), rtol=1e-3)
end


"""
    angleAdjacent2Opposite(angle::Angle, adjacent::Unitful.Length) :: Unitful.Length
    angleAdjacent2Opposite(angle::Angle, adjacent::Unitful.Length) :: Unitful.Length
For a right triangle, find the length of the 'opposite' leg, given `angle` and `adjacent`.
"""
function angleAdjacent2Opposite(angle::AbstractAngle, adjacent::AbstractLength) :: AbstractLength 
  T = typeof(adjacent)
  return T(adjacent * tan(angle))
end
angleAdjacent2Opposite(; angle::AbstractAngle, adjacent::AbstractLength) = angleAdjacent2Opposite( angle, adjacent )
@testitem "angleAdjacent2Opposite" begin
  using UnitTypes
  @test isapprox(angleAdjacent2Opposite( Radian(π/4), Meter(1) ), Meter(1), rtol=1e-3)
end


"""
    lawOfCosines(legA::Unitful.Length, legB::Unitful.Length, angleAB::Angle) :: Unitful.Length
    lawOfCosines(legA::Unitful.Length, legB::Unitful.Length, angleAB::Angle) :: Unitful.Length
For any triangle, finds the length of the unknown `legC` from `legA`, `legB`, and `angleAB` between them.
"""
function lawOfCosines(legA::AbstractLength, legB::AbstractLength, angleAB::AbstractAngle) :: AbstractLength 
  T = typeof(legA)
  # return T(sqrt( legA*legA + legB*legB -2*legA*legB*cos(angleAB)))
  return T(sqrt( toBaseFloat(legA)^2 + toBaseFloat(legB)^2 -2*toBaseFloat(legA)*toBaseFloat(legB)*cos(angleAB)))
end
lawOfCosines(; legA::AbstractLength, legB::AbstractLength, angleAB::AbstractAngle) = lawOfCosines( legA, legB, angleAB )
@testitem "lawOfCosines" begin
  using UnitTypes
  @test isapprox(lawOfCosines(Meter(1), Meter(1), Radian(Degree(135))), legLeg2Hypotenuse( Meter(1+√.5), Meter(√.5) ) , rtol=1e-3)
end

"""
    lawOfSines(legA::Unitful.Length, angleBC::Angle, angleCA::Angle) :: Unitful.Length
    lawOfSines(; legA::Unitful.Length, angleBC::Angle, angleCA::Angle) :: Unitful.Length
For any triangle with legs A, B, C and angles AB, BC, CA, so that `legA` is the open side of `angleBC`, finds legB corresponding to `angleCA`.
"""
function lawOfSines(legA::AbstractLength, angleBC::AbstractAngle, angleCA::AbstractAngle) :: AbstractLength 
  return legA * sin(angleCA)/sin(angleBC)
  # function lawOfSines(legA::Unitful.Length, angleBC::Angle, angleCA::Angle, showDiagram=false)
  # if showDiagram
  #   fig2 = figure()

  #   abc = uconvert(u"rad", angleBC)
  #   aca = uconvert(u"rad", angleCA)
  #   aab = (pi - abc - aca)u"rad"
  #   angleAB = uconvert(u"°", aab)

  #   # legA = 1u"m"
  #   legB = legA * sin(aca)/sin(abc)
  #   legC = legA * sin(aab)/sin(abc)

  #   vCA = [0;0]u"m" #vertex of angleCA
  #   vAB = vCA + legA*[cos(aca); sin(aca)]
  #   vBC = vCA + legA*[cos(aca); sin(aca)] + legB*[cos(abc); -sin(abc)]

  #   plot([ustrip(vAB[1]), ustrip(vBC[1])], [ustrip(vAB[2]), ustrip(vBC[2])], "bo-", ls="-", c="b") #[a,b] to make vectors, [a b] makes matrix
  #   plot([ustrip(vCA[1]), ustrip(vBC[1])], [ustrip(vCA[2]), ustrip(vBC[2])], "co-", ls="-", c="c")
  #   plot([ustrip(vAB[1]), ustrip(vCA[1])], [ustrip(vAB[2]), ustrip(vCA[2])], "mo-", ls="-", c="m")
  #   avg = mean([vAB, vBC])
  #   txtB = @sprintf("%3.3fmm", ustrip(u"mm", legB))
  #   text(ustrip(avg[1]), ustrip(avg[2]), "B[$txtB]", color="b", backgroundcolor=(1,1,1,0.5), alpha=0.8)
  #   avg = mean([vBC, vCA])
  #   txtC = @sprintf("%3.3fmm", ustrip(u"mm", legC))
  #   text(ustrip(avg[1]), ustrip(avg[2]), "C[$txtC]", color="c", backgroundcolor=(1,1,1,0.5), alpha=0.8)
  #   avg = mean([vCA, vAB])
  #   txtA = @sprintf("%3.3fmm", ustrip(u"mm", legA))
  #   text(ustrip(avg[1]), ustrip(avg[2]), "A[$txtA]", color="m", backgroundcolor=(1,1,1,0.5), alpha=0.8)
  #   text(ustrip(vAB[1]),ustrip(vAB[2]),"AB[$(uconvert(u"°",angleAB))]", color="c")
  #   text(ustrip(vBC[1]),ustrip(vBC[2]),"BC[$(uconvert(u"°",angleBC))]", color="m")
  #   text(ustrip(vCA[1]),ustrip(vCA[2]),"CA[$(uconvert(u"°",angleCA))]", color="b")
  #   title("lawOfSines()")
  #   ax = gca()
  #   ax.set_aspect("equal")
  #   grid()
  # end
end
lawOfSines(; legA::AbstractLength, angleBC::AbstractAngle, angleCA::AbstractAngle) = lawOfSines( legA, angleBC, angleCA )
@testitem "lawOfSines" begin
  using UnitTypes
  @test isapprox(lawOfSines( Meter(1), Radian(Degree(45)), Radian(Degree(45))), Meter(1), rtol=1e-3)
end

