# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 

using ArbNumerics #for elliptic_e below


export ellipticArcLength

"""
function ellipticArcLength(a::Number, b::Number, angle::Number )::Number
Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` through `angle` via elliptic integral:
L = b * elliptic_e( atan(a/b*tan(angle)), 1-a^2/b^2 )
"""
function ellipticArcLength(a::Number, b::Number, angle::Number )::Number
  # see: https://math.stackexchange.com/a/1123737/974011 

  if a < 0
    throw(DomainError(a, "major axis [$a] must be greater than 0"))
  end
  if b < 0
    throw(DomainError(b, "minor axis [$b] must be greater than 0"))
  end
  if a < b
    throw(DomainError(a, "major axis [$a] is smaller than minor axis [$b]"))
  end
  if pi/2 < angle
    throw(DomainError(angle, "angle[$angle] should be less than pi/2"))
  end
  if angle < -pi/2
    throw(DomainError(angle, "angle[$angle] should be greater than -pi/2"))
  end

  phi = atan( a/b*tan(angle))
  m = 1 - (a/b)^2
  return abs(b*elliptic_e( ArbReal(phi), ArbReal(m) ))
end

function ellipticArcLength(a::Unitful.Length, b::Unitful.Length, angle::Angle)
    return ellipticArcLength( ustrip(unit(a), a), ustrip(unit(a), b), ustrip(u"rad", angle)) * unit(a)
end

"""
Calculates the arc length of an ellipse from major axis `a` towards minor axis `b` between `star` and `stop`
"""
function ellipticArcLength(a::Number, b::Number, start::Number, stop::Number)
  lStart = ellipticArcLength(a,b, start)
  lStop = ellipticArcLength(a,b, stop)
  return lStop - lStart
end

