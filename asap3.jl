import blast, muscle

# Access input

f = open(ARGS[1], "r")
accessions = readlines(f)

# TODO: Arg parse

# Generate workers
# worker_procs = addprocs(min(Sys.CPU_CORES - 1, length(accessions)))
worker_procs = addprocs(Sys.CPU_CORES - 1)
@everywhere using blast, muscle

# Blast sequences
# try

    blast_results = pmap(blast.recursive_search, accessions)


    partition_accessions, partition_taxa_ref = collect(zip(blast_results...))

    #Find common taxa
    taxa_lists = [collect(values(d)) for d in partition_taxa_ref]
    common_taxa = intersect(taxa_lists...)

    #Create a master list of taxa
    taxa_ref = merge(partition_taxa_ref...)

    # Cull taxa
    partition_taxa = [map(a->taxa_ref[a], p) for p in partition_accessions]
    idxs = [find(t -> in(t, common_taxa), p) for p in partition_taxa]
    culled_accessions = [partition_accessions[i][idxs[i]] for i in 1:length(idxs)]

    #Get full sequences, alert for abnormally small or large (2SD)
    blast.full_sequences(culled_accessions)

    full_seqs = pmap(blast.full_sequences, culled_accessions)
    header_seqs = map((x,y)->collect(zip(x,y)), culled_accessions, full_seqs)

    # Align partitions, save FASTA formatted output
    # Make headers taxa
    partition_alignments = pmap(x->muscle.align(x, "isaiah_bryant@brown.edu"), header_seqs)
    print(partition_alignments)


    #Build individual trees

    #Calculated RF distances between trees

    #Build gene network

    #Concatenate sequences and build consensus tree


    # Close the workers we created
# finally
    rmprocs(worker_procs)
    close(f)
# end
