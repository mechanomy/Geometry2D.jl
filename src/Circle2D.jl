


module Circle2D
  using Unitful, Unitful.DefaultSymbols
  using PyPlot

  include("Point2D.jl")


  # A circle has a <center::Geometry2D.Point> and a <radius::Unitful.Length>
  struct Circle
    center::Point2D.Point #[x,y] of the pulley center
    radius::Unitful.Length
  end

  function plotCircle( circ::Circle, col )
    th = range(0,2*pi,length=100)
    x = ustrip(circ.center.x) .+ ustrip(circ.radius).*cos.(th)
    y = ustrip(circ.center.y) .+ ustrip(circ.radius).*sin.(th)
    plot(x,y, color=col, alpha=0.5 )
  end



end