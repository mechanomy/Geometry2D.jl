# Additional Unitful definitions

@derived_dimension Radian dimension(u"rad")
# @derived_dimension Degree dimension(2*pi)
# @unit deg "deg" Degree 360/2*pi false
Angle{T} = Union{Quantity{T,NoDims,typeof(u"rad")}, Quantity{T,NoDims,typeof(u"°")}} where T


