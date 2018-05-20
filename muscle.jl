module muscle
import Requests: get, put, post
export align

    function align(seqs, email_to; kwargs...)

        # TODO: ARGPARSE

        fasta_seqs = []
        for (header, sequence) in seqs
            push!(fasta_seqs, ">$header\n$sequence\n")
        end

        # Prepare data
        params = Dict(kwargs)
        params[:email] = email_to
        params[:sequence] = join(fasta_seqs)
        params[:format] = "fasta" # phylip for RaxML
        base_url = "http://www.ebi.ac.uk/Tools/services/rest/muscle/run/"

        # Run job
        job_id = readstring(post(base_url; data=params))
        println("MUSCLE JOB ID: $job_id")

        # Check status
        status_url = "http://www.ebi.ac.uk/Tools/services/rest/muscle/status/$job_id"
        status = readstring(get(status_url))

        while status == "RUNNING"
            println("STATUS: $status")
            sleep(10)
            status = readstring(get(status_url))
        end

        if status == "FINISHED"
            response =  get("http://www.ebi.ac.uk/Tools/services/rest/muscle/result/$job_id/aln-fasta")
            return readstring(response)
        else
            println("STATUS: $status")
        end
    end
end
