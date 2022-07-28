# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#Various convenient and explicit Trigonometry relations

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
For a right triangle, find the length of the hypotenuse from the shorter legs `a` and `b`.
"""
function legLeg2Hypotenuse( a::Unitful.Length, b::Unitful.Length ) :: Unitful.Length
  return sqrt( a^2 + b^2 )
end

"""
For a right triangle, find the length of the third leg from hypotenuse `hyp` and `leg`.
"""
function legHypotenuse2Leg( leg::Unitful.Length, hyp::Unitful.Length  ) :: Unitful.Length
  if hyp < leg
    throw( ArgumentError("leg[$leg] should be < than hyp[$hyp]") )
  end
  return sqrt( hyp^2 - leg^2 )
end

"""
For a right triangle, find the length of the 'adjacent' leg, given `angle` and `opposite`.
"""
function angleOpposite2Adjacent(angle::Angle, opposite::Unitful.Length) :: Unitful.Length
  return opposite / tan(angle)
end

"""
For a right triangle, find the length of the 'opposite' leg, given `angle` and `adjacent`.
"""
function angleAdjacent2Opposite(angle::Angle, adjacent::Unitful.Length) :: Unitful.Length
  return adjacent * tan(angle)
end

"""
Finds the length of the unknown `legC` from `legA`, `legB`, and `angleAB` between them.
"""
function lawOfCosines(legA::Unitful.Length, legB::Unitful.Length, angleAB::Angle) :: Unitful.Length
  return sqrt( legA^2 + legB^2 -2*legA*legB*cos(angleAB))
end

"""
For any triangle with legs A, B, C and angles AB, BC, CA, so that `legA` is the open side of `angleBC`, finds legB corresponding to `angleCA`.
"""
function lawOfSines(legA::Unitful.Length, angleBC::Angle, angleCA::Angle)
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


