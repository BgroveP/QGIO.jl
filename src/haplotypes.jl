
function haplotypes(path;
    loci=DataFrame(chromosome=String[], position=Int[], identifier=String[]),
    ancestries::DataFrame=DataFrame(individual=String[], population=String[]),
    omits::DataFrame=DataFrame(individual=String[], haplotype=Int[]))

    sdf = _mergesamples(samples(path), ancestries, omits)

    # Get output row
    sort!(sdf, "population")
    sdf.xrow = 1:nrow(sdf)
    sort!(sdf, "index")

    # 
    if nrow(loci) == 0
        loci = QGIO.loci(path)[:,[:chromosome, :position, :identifier]]
    end

    # Initialize
    x = zeros(Int8, nrow(sdf), nrow(loci))
    locusdict = Dict(zip(loci.chromosome, loci.position, loci.identifier) .=> 1:nrow(loci))
    buffer = QGIO.create_buffer()
    file = QGIO.open_vcf(path)
    haplotypes = zeros(Int8, nrow(sdf))
    while QGIO.readline!(file,buffer)

        if buffer[1] != UInt8('#')
            xcol = get!(locusdict, (QGIO._buffer_chromosome(buffer),  
            _buffer_position(buffer), 
            QGIO._buffer_identifier(buffer)), 0)

            if xcol > 0 
                 QGIO._buffer_haplotypes!(haplotypes, buffer)
                x[:,xcol] = haplotypes
            end
        end

    end

    # Resort
    sort!(sdf, "xrow")

    return x, sdf[:,[:individual, :haplotype, :population, :xrow]]
end

