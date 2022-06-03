
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