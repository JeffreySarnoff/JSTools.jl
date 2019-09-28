module JSTools

export istypesafe, istypeswift    # modules/ReturnType.jl

include("modules/ReturnType.jl")  # istypesafe(fn, argtypes), istypeswift(fn, argtypes)
using .ReturnType

end # module
