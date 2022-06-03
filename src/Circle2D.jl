

# Circle2D.jl is a member of Geometry2D.jl via the include()s listed there.


"""A circle has a `center` and a `radius`"""
struct Circle
  center::Point #[x,y] of the pulley center
  radius::Unitful.Length
end
@kwdispatch Circle()
@kwmethod Circle(; center::Point, radius::Unitful.Length ) = Circle(center, radius)


"""Returns the Point on `c` at angle `a`"""
function pointOnCircle( c::Circle, a::Angle ) :: Point
    # """Returns a 2D vector from the `origin` along `angle` from global reference axis 'x' with magnitude `length`.
    # """
    # function vectorLengthAngle(length::Unitful.Length, angle::Radian) :: Vector{Unitful.Length}
    #     return length * [cos(angle); sin(angle); 0]
    # end
  return c.center + Delta(c.radius*cos(a), c.radius*sin(a))
end


"""Given Circles `circleA` and `circleB`, tests whether points on their edge at angles `thA`, `thB` define a mutually tangent segment"""
function isSegmentTangent( circleA::Circle, circleB::Circle, thA::Radian, thB::Radian, tol::Number=1e-3)
    #define rA and rB from 0,0
    rA = vectorLengthAngle(circleA.radius, thA) 
    rB = vectorLengthAngle(circleB.radius, thB)
    #get unit vectors
    uA = normalize(rA)
    uB = normalize(rB)

    pA = addPointVector( circleA.center, rA )
    pB = addPointVector( circleB.center, rB )
    rSeg = subtractPoints(pA, pB)
    uSeg = normalize(rSeg)
    crossA = cross([ustrip(uA[1]), ustrip(uA[2]), ustrip(uA[3])], [ustrip(uSeg[1]),ustrip(uSeg[2]),ustrip(uSeg[3])])
    crossB = cross([ustrip(uB[1]), ustrip(uB[2]), ustrip(uB[3])], [ustrip(uSeg[1]),ustrip(uSeg[2]),ustrip(uSeg[3])])

    uk = [0;0;1]
    dotA = dot(crossA, uk)
    dotB = dot(crossB, uk)

    return abs(1-abs(dotA) + 1-abs(dotB)) < ustrip(tol)
end 





# using PyPlot
# function plotCircle( circ::Circle, col )
#   th = range(0,2*pi,length=100)
#   x = ustrip(circ.center.x) .+ ustrip(circ.radius).*cos.(th)
#   y = ustrip(circ.center.y) .+ ustrip(circ.radius).*sin.(th)
#   plot(x,y, color=col, alpha=0.5 )
# end

function testCircle2D()
  @testset "Circle constructors" begin
    p = Point(1u"mm",2u"inch")
    r = 5mm
    c = Circle(p, r) 
    @test c.center.x == 1u"mm" && c.center.y == 50.8u"mm" 
    @test c.radius == 5u"mm"
    @test typeof( Circle(center=p, radius=r) ) <: Circle
  end


  @testset "Circle isSegmentTangent" begin

  end
end #testCircle()



