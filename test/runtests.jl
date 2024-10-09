# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

using TestItemRunner # https://github.com/julia-vscode/TestItemRunner.jl 
@run_package_tests verbose=true
# @run_package_tests verbose=true filter=ti->(occursin("Point2D", ti.filename))
# @run_package_tests verbose=true filter=ti->(occursin("Vector2D", ti.filename))
# @run_package_tests verbose=true filter=ti->(occursin("Triangle2D", ti.filename))
# @run_package_tests verbose=true filter=ti->(occursin("Circle2D", ti.filename))
# @run_package_tests verbose=true filter=ti->(occursin("Spiral2D", ti.filename))
# @run_package_tests verbose=true filter=ti->(occursin("Transform2D", ti.filename))

# @run_package_tests verbose=true filter=ti->(occursin("Ellipse2D", ti.filename))

# close("all")

; #don't return the last thing