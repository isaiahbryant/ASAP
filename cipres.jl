module cipres

import HTTP: get, post, Form
export build_tree

function build_tree(infile, username, password, key;
                    validate = false,
                    email = false)

    base_url = "https://cipresrest.sdsc.edu/cipresrest/v1/job/$username"

    if validate == true
        base_url *= "/validate"
        response = readstring(`curl -u $username:$password -H cipres-appkey:$key $base_url -F metadata.statusEmail=false -F tool=RAXMLHPC8_REST_XSEDE -F input.infile_=$infile -F vparam.bootstrap_value_=100 -F vparam.choose_bootstop_=specify -F vparam.choose_bootstrap_=b -F vparam.convergence_criterion_=0 -F vparam.datatype_=protein -F vparam.disable_ratehet_=0 -F vparam.disable_seqcheck_=0 -F vparam.intermediate_treefiles_=0 -F  vparam.more_memory_=0 -F vparam.mulcustom_aa_matrices_=0 -F vparam.no_bfgs_=0 -F vparam.number_cats_=25 -F vparam.outsuffix_=result -F vparam.parsimony_seed_val_=12345 -F vparam.printbrlength_=0 -F vparam.prot_matrix_spec_=DAYHOFF -F vparam.prot_sub_model_=PROTCAT -F vparam.provide_parsimony_seed_=1 -F vparam.rearrangement_yes_=0 -F vparam.runtime_=0.25 -F vparam.seed_value_=12345  -F vparam.select_analysis_=fd -F vparam.use_emp_freqs_=F`)
        return response
    end

    # Input
    input_params = Dict()

    # Run
    response = readstring(`curl -u $username:$password -H cipres-appkey:$key $base_url -F metadata.statusEmail=false -F tool=RAXMLHPC8_REST_XSEDE -F input.infile_=$infile -F vparam.bootstrap_value_=100 -F vparam.choose_bootstop_=specify -F vparam.choose_bootstrap_=b -F vparam.convergence_criterion_=0 -F vparam.datatype_=protein -F vparam.disable_ratehet_=0 -F vparam.disable_seqcheck_=0 -F vparam.intermediate_treefiles_=0 -F  vparam.more_memory_=0 -F vparam.mulcustom_aa_matrices_=0 -F vparam.no_bfgs_=0 -F vparam.number_cats_=25 -F vparam.outsuffix_=result -F vparam.parsimony_seed_val_=12345 -F vparam.printbrlength_=0 -F vparam.prot_matrix_spec_=DAYHOFF -F vparam.prot_sub_model_=PROTCAT -F vparam.provide_parsimony_seed_=1 -F vparam.rearrangement_yes_=0 -F vparam.runtime_=0.50 -F vparam.seed_value_=12345  -F vparam.select_analysis_=fd -F vparam.use_emp_freqs_=F`)

    status_url = matchall(r"(?<=<url>).*(?=</url>)", response)[1]

    # Check Status
    response = readstring(`curl -u $username:$password -H cipres-appkey:$key $status_url`)
    wait_time = matchall(r"(?<=<minPollIntervalSeconds>).*(?=</minPollIntervalSeconds>)", response)[1]
    wait_time = parse(Int8, wait_time)
    completed = matchall(r"(?<=<terminalStage>).*(?=</terminalStage>)", response)[1]

    while completed == "false"
        println("Building tree. This may take a while...")
        sleep(wait_time)
        response = readstring(`curl -u $username:$password -H cipres-appkey:$key $status_url`)
        completed = matchall(r"(?<=<terminalStage>).*(?=</terminalStage>)", response)[1]
    end

    # Check for failure
    failed = matchall(r"(?<=<terminalStage>).*(?=</terminalStage>)", response)[1]
    if failed == "true"
        return response
    end

    # Get results
    results_url = status_url * "/output"
    response = readstring(`curl -u $username:$password -H cipres-appkey:$key $results_url`)
    return response

end

# Calculate RF distances
function rfdist()
    #TODO
end

end
