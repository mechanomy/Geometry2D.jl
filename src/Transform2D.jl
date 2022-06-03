
using Unitful, Unitful.DefaultSymbols


# const UnitVector{T} = SVector{3,T}
# const ui = UnitVector([1,0,0])
# const uj = UnitVector([0,1,0])
# const uk = UnitVector([0,0,1])

export Rz, Tx, Ty

"""Make a 2D Vector2D of <x>,<y>"""
function point2vec(p::Point)
    return [p.x; p.y; 1*unit(p.x)]
end

function vec2point(v::Vector{<:Unitful.Length})
  return Point(v[1], v[2])
end

"""Create a 2D rotation matrix effecting a rotation of <angle>"""
function Rz(angle::Number)
    return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
end
function Rz(angle::Angle)
    return [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]
end

function Rz(p::Point, a::Angle)
  return vec2point( Rz(a) * point2vec(p) )
end


"""Create a 2D translation matrix translating along local x by <a>"""
function Tx(a::Number) #homogeneous transformation matrices are multiplied and therefore should be unitless
    return [1 0 a; 0 1 0; 0 0 1]
end
function Tx(p::Point, d::Unitful.Length)
  return vec2point( Tx(ustrip.(unit(p.x),d)) * point2vec(p) )
end

"""Create a 2D translation matrix translating along local y by <b>"""
function Ty(b::Number)
    return [1 0 0; 0 1 b; 0 0 1]
end
function Ty(p::Point, d::Unitful.Length)
  return vec2point( Ty(ustrip.(unit(p.y),d)) * point2vec(p) )
end


function testTransform2D()
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
end
