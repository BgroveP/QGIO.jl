

function subset(inpath, outpath; samples::Vector{String}=[""], loci::DataFrame=DataFrame(chromosome=String[], position=Int[], identifier=String[]))
    # get sample indices
    allsamples = QGIO.samples(inpath)
    thissamples = [1:9; 9 .+ [findfirst(s .== allsamples) for s in samples]]
    # get locus dictionary
    if nrow(loci) == 0
        loci = QGIO.loci(inpath)
    end
    locusdict = Dict(zip(loci.chromosome, loci.identifier) .=> true)

    # 
    infile = QGIO.open_vcf(inpath)
    outfile = GZip.open(outpath, "w")
    # Print previous header
    for l in QGIO.header(inpath)
        print(outfile, l)
    end
    # Print new note
    print(outfile, "##QGIO.jl=subsetted")
    # Subset
    readlock = ReentrantLock()
    writelock = ReentrantLock()
    @threads for i in 1:nthreads()
        buffer = QGIO.create_buffer()
        notendofffile = false
        @lock readlock notendofffile = QGIO.readline!(infile, buffer)
        while notendofffile
            if ~all(buffer[1:2] .== UInt8('#'))
                if (buffer[1] == UInt8('#')) | (get!(locusdict, (QGIO._buffer_chromosome(buffer),QGIO._buffer_identifier(buffer)), false))
                    t = _buffer_subset(buffer, thissamples)
                    @lock writelock begin 
                        @views print.(outfile, Char.(buffer[t]))
                        print(outfile, '\n')
                    end
                end
            end
        @lock readlock notendofffile = QGIO.readline!(infile, buffer)
        end
    end
    close(outfile)
end

