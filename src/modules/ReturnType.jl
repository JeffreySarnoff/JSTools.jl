module ReturnType

export istypestable, istypeswift

using Base: uniontypes

"""
    istypestable(fn, argtypes)

`fn` returns values of a stable type

if `istypestable(fn, argtypes)`
then `y = fn(args)` supports fast dispatch on `y`
"""
function istypestable(fn, argtypes::Tuple)
    arg_types = typed_as_tuple(argtypes)
    rtn_type = Base.return_types(fn, arg_types)[1]
    return isconcretetype(rtn_type)
end

istypestable(fn, argtype) = istypestable(fn, (argtype,))
istypestable(fn) = istypestable(fn, ())


#=
   To permit the composed return types `Union{Nothing, Type}`, `Union{Missing, Type}`
   to resolve supporting fast dispatch, where Type may be a Union of two `isbitstype` types,
   set `FastDispatchMax = 2`.  Otherwise set `FastDispatchMax = 3`.
=#

"""
    FastDispatchMax

`is_type_stablish(fn, argtypes)` is true if `is_type_stable(fn, argtypes)` or
 if the type returned is a Union of no more than this many `isbitstype` types.
"""
const FastDispatchMax = 2

"""
     istypeswift(fn, argtypes; fastdispatch::Int=FastDispatchMax)
                                                                        
`fn` returns values of a stable type, or 
`fn` returns values from a Union of `FastDispatchMax` many `isbitstype` types
                                                                        
if `istypeswift(fn, argtypes)` then `y = fn(args)` supports fast dispatch on `y`
"""
function istypeswift(fn, argtypes::Tuple; fastdispatch::Int=FastDispatchMax)
    arg_types = Tuple_from_typestuple(argtypes)
    rtn_type = Base.return_types(fn, arg_types)[1]
    if isa(rtn_type, Union)
       (tally_types(rtn_type) > fastdispatch) && return false
       all(isbitstype.(uniontypes(rtn_type))) || return false
    elseif isa(rtn_type,Tuple)
       for item in tupletypes(rtn_type)
           ((isa(item, Union) && tally_types(item) > fastdispatch) || !isbitstype(item)) && return false
       end    
    else
       return isconcretetype(rtn_type)
    end
end

is_type_stablish(fn, argtype) = is_type_stablish(fn, (argtype,))
is_type_stablish(fn) = is_type_stablish(fn, ())

"""
    Tuple_from_typestuple

converts a tuple (`(Int64, String)`) to a Tuple (`Tuple{Int64, String}`)
"""
Tuple_from_typestuple(items::NTuple{N,T}) where {T,N} = Tuple{items...,}
Tuple_from_typestuple() = Tuple{}

"""
    tuple_types

obtain the values in a Tuple (`Tuple{Int64, String}`) as a tuple (`(Int64, String)`) 
""" 
tuple_types(::Type{T}) where {T<:Tuple} = (T.parameters...,)

"""
    union_types

obtain the types in a Union (`Union{Int64, String}`) as a tuple (`(Int64, String)`) 
"""
union_types(x::Union) = (Base.uniontypes(x)...,)

"""
    tally_types(x::Union)

count the types in a Union (`Union{Int64, String}` ==> 2) 
count the types in a Tuple (`Tuple{Int64, String}` ==> 2) 
"""
tally_types(x::Union) = length(union_types(x))
tally_types(x::Tuple) = length(tuple_types(x))

end # module
