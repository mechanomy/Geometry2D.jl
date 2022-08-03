# Geometry2D.jl
Basic shapes and related geometrical concepts come up frequently, this basic module defines structures and functions providing common calculations.
This module is not attempting to be a 2D sketcher but rather provides clear, explicit, and verbose functions that improve users' maintainability and conceptual clarity.

Included entities/concepts:
* Points
* Triangles
* Circles
* Ellipses
* Spirals
* Homogeneous transforms

Many more entities and functions are under consideration, pending need.
**Please open an [enhancement issue](https://github.com/mechanomy/Geometry2D.jl/issues/new/choose) to help us prioritize our efforts.**

## Installation
```julia
using Pkg
Pkg.add(url="https://github.com/mechanomy/Geometry2D.jl.git")
```
## Basic Example
```@example
using Unitful, Unitful.DefaultSymbols
using Plots
using Geometry2D

p = Point(1mm,2u"inch")
plot(p, label="Point", title="Basic Example", aspect_ratio=:equal)

pa = Point(1mm,1u"inch")
r = 50mm
ca = Circle(pa, r)
plot!(ca, label="Circle A")

cb = Circle(5mm, 50mm, 20mm)
plot!(cb, label="Circle B")
```

## API
```@meta
CurrentModule= Geometry2D
```

```@autodocs
Modules=[Geometry2D]
```
