
function readline!(s::GZip.GZipStream, b::Vector{UInt8})
    # Initialize 
    _reset_buffer!(b)
    p::Union{Int,Nothing} = 1

    # Read until we either hit the end of the file, or a newline
    while !eof(s)
        gzgets(s, pointer(b) + p - 1, length(b) - p + 1) # Reads into buffer
        p = findnext(x -> x == UInt8('\0'), b, p) # Finds the \0 symbol which marks the end of the input read above
        if p == 1
            return false
        elseif ~isnothing(p) && (b[p-1] == UInt8('\n')) # Did we find a newline?
            return true # yes: stop here with success
        else
            resize!(b, length(b) + READLINE_BUFFER_SIZE) # no: grow the vector and go again
        end
    end
    # Reached EOF without finding a newline

    return false
end

# Emre observed the following error:
#Stacktrace:
#[1] macro expansion
#   @ ./iostream.jl:43 [inlined]
#[2] readline!(s::IOStream, b::Vector{UInt8})
#   @ QGIO ~/.julia/packages/QGIO/pLEiG/src/readline.jl:28
#[3] loci(path::String)
#   @ QGIO ~/.julia/packages/QGIO/pLEiG/src/loci.jl:22
#[4] haplotypes(path::String; loci::DataFrames.DataFrame, ancestries::DataFrames.DataFrame, omits::DataFrames.DataFrame)
#   @ QGIO ~/.julia/packages/QGIO/pLEiG/src/haplotypes.jl:16
#[5] haplotypes(path::String)
#   @ QGIO ~/.julia/packages/QGIO/pLEiG/src/haplotypes.jl:2
#[6] top-level scope
#   @ REPL[1583]:1
function readline!(s::IOStream, b::Vector{UInt8})
    d::UInt8 = UInt8('\n')
    p::Int = 1
    while !eof(s)
        Base.@_lock_ios s n = Int(ccall(:jl_readuntil_buf, Csize_t, (Ptr{Cvoid}, UInt8, Ptr{UInt8}, Csize_t), s.ios, d, pointer(b, p), (length(b) - p + 1) % Csize_t))
        p += n
        if b[p-1] == d
            return true # yes: stop here with success
        else
            resize!(b, length(b) + READLINE_BUFFER_SIZE) # no: grow the vector and go again
        end
    end
    return false
end
