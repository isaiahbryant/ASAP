module blast
import Requests: get, put, post
export parse_xml, blast_search, taxa, full_sequences

    # TODO: add support for all parameters
    function blast_search(protein;
                          program="blastp",
                          psi_blast=false,
                          db="nr",
                          expect::Float64=1e-256,
                          hitlist_size::Int64=100,
                          filter="mL",
                          format_type="XML",
                          get_accessions=true)

        """
        Input: a Entrez protein accession or sequence
        Output: NCBI server response in the requested format
        """

        blast_params = ["CMD=Put"]
        push!(blast_params, "QUERY=$protein")
        push!(blast_params, "PROGRAM=$program")
        push!(blast_params, "DATABASE=$db")
        push!(blast_params, "FILTER=$filter")
        push!(blast_params, "HITLIST_SIZE=$hitlist_size")
        push!(blast_params, "EXPECT=$expect")
        if psi_blast == true
            push!(blast_params, "RUN_PSIBLAST=on")
            push!(blast_params, "WORD_SIZE=2")
        end


        #  Build search URL
        base_url = "https://blast.ncbi.nlm.nih.gov/Blast.cgi?"
        search_params = join(blast_params, "\&")
        blast_url = "$base_url$search_params"

        #  Execute query and parse response from NCBI
        response_text = readstring(post(blast_url))

        open("/Users/ibryant/research/ptb/output/blast_response.txt", "w") do f
            write(f, response_text)
        end

        RID = match(r"(?<=RID = )\w*", response_text).match
        RTOE = parse(Int64, match(r"(?<=RTOE = )\w*", response_text).match)

        # Check if query is completed, collect result
        sleep(RTOE)
        request_params = "CMD=Get&RID=$RID&FORMAT_TYPE=$format_type"
        response = post("$base_url$request_params")
        response_text = readstring(response)
        status = match(r"(?<=Status=)\w*", response_text)

        while status != nothing
            if status.match == "WAITING"
                println("Searching NCBI BLAST $db for: $protein...")
                sleep(RTOE)
                response = post("$base_url$request_params")
                response_text = readstring(response)
                status = match(r"(?<=Status=)\w*", response_text)
            end
        end

        hits = readstring(response)

        # If necessary, parse accessions
        if get_accessions == true && format_type == "XML"
            entrez_ids = blast.parse_xml(hits)

            # TODO: remove print statement after debugging
            num_hits=length(entrez_ids)
            println("$num_hits results found in $db for $protein")
            # print(entrez_ids)
            return entrez_ids
        end

        return hits
    end

    function parse_xml(xml)
        """
        Input: A BLAST output string having XML format or an XML file object
        Output: String array of Accession IDs for BLAST hits
        """

        if typeof(xml) == IOStream
            xml_string = readstring(xml)
            return matchall(r"(?<=<Hit_accession>).*(?=</Hit_accession>)",
                xml_string)
        else
            return matchall(r"(?<=<Hit_accession>).*(?=</Hit_accession>)",
                xml)
        end
    end



    # TODO: PSI-BLAST
    # TODO: use DBSOURCE field to find nucleotide sequences


    function taxa(accession)
        response = readstring(get("https://eutils.ncbi.nlm.nih.gov/" *
                              "entrez/eutils/" *
                              "elink.fcgi?dbfrom=protein&" *
                              "db=taxonomy&id=$accession"))
        try
            return matchall(r"(?<=<Id>).*(?=</Id>)",response)[2]
        catch
            println("$accession returned no taxa results")
            print(response)
            exit()
            return nothing
        end
    end

    function full_sequences(accessions)
        #TODO: add retmode support
        ids = join(accessions, ",")
        response = readstring(get("http://eutils.ncbi.nlm.nih.gov/entrez/" *
                                  "eutils/efetch.fcgi?db=protein&rettype=" *
                                  "fasta&retmode=xml&id=$ids"))
        return matchall(r"(?<=<TSeq_sequence>).*(?=</TSeq_sequence>)",response)
    end

    # scope boundary based on taxonmy or up to x hits per species
    # limit taxa as parm into blast? restrict to refseq
    # could limit to 500 taxa per partition
    # defined taxa to be present
    # run TNT on CIPRES
    # run MUSCLE on CIPRES

    function recursive_search(accession; num_taxa=500, taxon_limit=1,
                              partition_size=500, hitlist_size=100,
                              max_iter=3)


        used_ids = []
        search_queue = [accession]
        search_taxon = blast.taxa(accession)
        taxa_counts = Dict{String,Int64}(search_taxon => 1)
        hits = [accession]
        taxa = Dict(accession => search_taxon)
        iter_no_impr = 0
        prev_num_hits = 0

        # Add flexibility to limits
        while !isempty(search_queue) && length(taxa) < num_taxa && length(hits) < partition_size && iter_no_impr < max_iter

            # Grab next ID to search
            curr_id = shift!(search_queue)
            println("Search Accession: $curr_id")
            push!(used_ids, curr_id)

            # Conduct BLAST search on sequence
            results = blast.blast_search(curr_id; hitlist_size=100)

            # Filter out redundant results
            #new_results = results[find(x -> !in(used_ids, x), results)]
            new_results = results[find(x -> !in(x, used_ids), results)]

            # Grab taxa information
            #TODO change to pmap
            #result_taxa = [blast.taxa(a) for a in new_results]
            result_taxa = pmap(blast.taxa, new_results)

            #Update hits with accessions abiding by taxon_limit
            for (a, t) in zip(new_results, result_taxa)
                if length(hits) < 500
                    taxon_count = get(taxa_counts, t, 0)

                    if taxon_count == 0
                        taxa_counts[t] = 1
                        push!(search_queue, a)
                        push!(used_ids, a)
                        push!(hits, a)
                        taxa[a] = t
                    elseif taxon_count < taxon_limit
                        taxa_counts[t] += 1
                        push!(search_queue, a)
                        push!(used_ids, a)
                        push!(hits, a)
                        taxa[a] = t
                    end

                else
                    break
                end
            end
            @printf("%i hits found so far \n", length(hits))

            if length(hits) > prev_num_hits
                prev_num_hits = length(hits)
            else
                iter_no_impr += 1
            end
        end

        return (hits, taxa)
    end
end
