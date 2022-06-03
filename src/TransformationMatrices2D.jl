
module TransformationMatrices2D
  using Unitful, Unitful.DefaultSymbols

  include("Point2D.jl")

  @derived_dimension Radian dimension(u"rad")
  Angle{T} = Union{Quantity{T,NoDims,typeof(u"rad")}, Quantity{T,NoDims,typeof(u"°")}} where T

  # %2D
  # export Vec, Rz, Tx, Ty
  """Make a 2D vector of <x>,<y>"""
  function Vec(x::Number,y::Number)
      return [x; y; 1]
  end

  """Create a 2D rotation matrix effecting a rotation of <angle>"""
  function Rz(angle::Number)
      return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
  end
  function Rz(angle::Angle)
      return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
  end

  """Create a 2D translation matrix translating along local x by <a>"""
  function Tx(a::Number)
      return [1 0 a; 0 1 0; 0 0 1]
  end
  function Tx(a::Unitful.Length)
      return [1 0 ustrip(a); 0 1 0; 0 0 1]*unit(a)
  end

  """Create a 2D translation matrix translating along local y by <b>"""
  function Ty(b::Number)
      return [1 0 0; 0 1 b; 0 0 1]
  end
  function Ty(b::Unitful.Length)
      return [1 0 0; 0 1 ustrip(b); 0 0 1]*unit(b)
  end



end



function testTransformatinMatrices2D()

function testRotation()
  # rotate ux by 45deg = 0.707;0.707
  sq22 = sqrt(2)/2
  a = Geometry2D.Vec(1,0)
  rz = Geometry2D.Rz(deg2rad(45))
  a45 = rz *a
  ret = Utility.eqTol(sq22, a45[1]) && Utility.eqTol(sq22, a45[2])
  return ret
end
function testTranslation()
  a = Geometry2D.Vec(1,0)
  tx = Geometry2D.Tx(1)
  ty = Geometry2D.Ty(1)
  # ty = Ty(1)
  res = tx * ty * a
  return Utility.eqTol(res[1], 2) && Utility.eqTol(res[2], 1)
end
@testset "2D rotation and translation matrices" begin
  @test testRotation()
  @test testTranslation()
end


# function test_line()
#   a = Geometry2D.Point(0,0)
#   l = Geometry2D.line(a, )
# end
# @testset "line construct" begin
#   @test test_line()

# end
end
