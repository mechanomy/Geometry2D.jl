# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Additional Unitful definitions

@derived_dimension Radian dimension(u"rad")
# @derived_dimension Degree dimension(2*pi)
# @unit deg "deg" Degree 360/2*pi false
Angle{T} = Union{Quantity{T,NoDims,typeof(u"rad")}, Quantity{T,NoDims,typeof(u"°")}} where T

 
"""`angleWrap(angle::Radian) :: Radian`
Wraps `angle` between 0 and 2π.
"""
function angleWrap(angle::Radian)
  return (ustrip(u"rad", angle) + 2*pi)%(2*pi) * 1.0u"rad"
end

"""`angleWrap(angle::Real) :: Real`
Wraps `angle` between 0 and 2π.
"""
function angleWrap(angle::Real) :: Real
  return (angle + 2*pi)%(2*pi)
end


function testUnitfuller()
  @testset "angleCorrect" begin
    @test angleWrap(-7rad) ≈ 2*π-7
    @test angleWrap(-1rad) ≈ 2*π-1
    @test angleWrap(1rad) ≈ 1
    @test angleWrap(7rad) ≈ 7-2*π

    @test angleWrap(-7) ≈ 2*π-7
    @test angleWrap(-1) ≈ 2*π-1
    @test angleWrap(1) ≈ 1
    @test angleWrap(7) ≈ 7-2*π
  end

end