using blast
#@everywhere using blast
using muscle
using cipres
import HTTP: get, put, post

# Test Blast Search functionality
# f = open("/Users/ibryant/research/ptb/output/blast_search_output.txt", "w")
# h = blast.blast_search("NP_062570.1")
# println(h)
# write(f, h)
# close(f)

# Test XML Parse functionality
# f = open("/Users/ibryant/research/ptb/output/blast_id_output.txt", "w")
# a = blast.parse_xml(h)
# println(a)
# writedlm(f, a, delim='\n')
# close(f)




# Test parallel blast functionality
# h = asap.psearch(["NP_062570.1","NP_000509"]; hitlist_size=10)
# println(h)
# worker_procs = addprocs(Sys.CPU_CORES - 1)
# @everywhere using blast
# accessions = ["NP_062570.1","XP_024308529.1"]
# all_results = pmap(blast.recursive_search, accessions)
# println(all_results)
# rmprocs(worker_procs)




# Test recursive search
# h = blast.recursive_search("NP_062570.1")
# println(length(h))
# println(h)

# results = ["XP_021508443", "XP_005329626", "XP_011926708", "XP_004395960", "XP_021778786", "XP_012664511", "OWK14844", "XP_019504585", "XP_008687048", "XP_023503034", "XP_005691440", "XP_021018010", "XP_012519021", "XP_004690866", "XP_003510305", "XP_004054121", "XP_011803849", "XP_019589454", "XP_004753200", "XP_006970766", "OBS68930", "XP_001928626", "NP_062570.1", "XP_004595391", "XP_017533655", "XP_019656660", "XP_006047264", "XP_004276729", "XP_007058339", "XP_024614226", "XP_006149324", "XP_012878648", "XP_020014993", "NP_001178284", "NP_063928", "NP_071574", "XP_011760716", "XP_004385033", "XP_014919295", "XP_023352808", "XP_008140888", "XP_006865440", "XP_019323146", "XP_019833613", "XP_007448746", "XP_010366676", "XP_005904743", "XP_014131739", "XP_005955336", "XP_019394405", "XP_005344450", "XP_007189657", "XP_005403117", "XP_013963408", "XP_014714250", "XP_021562402", "PNJ82115", "XP_022373084", "XP_020745468", "XP_012927272", "XP_007936323", "KFU93302", "XP_011965727", "XP_008003265", "XP_006910056", "XP_008837531", "XP_015357922", "XP_021554288", "XP_010994220", "XP_016058698", "XP_015287218", "XP_013814089", "XP_011819913", "XP_003932189", "XP_023097120", "XP_008516701", "XP_021042603", "XP_007079613", "NP_062570", "XP_004668534", "NP_001248225", "XP_007104608", "XP_006113794", "XP_023576434", "XP_016780001", "XP_024051932", "XP_006894701", "XP_004430097", "XP_012637659", "XP_021088982", "XP_008586002", "XP_006209556", "XP_009003087", "XP_012302611", "XP_024422696", "XP_004017377", "XP_006751279", "XP_017399843", "XP_022453661", "XP_023061402", "XP_005491615", "XP_007539854"]

# sequences = blast.full_sequences(results)
# seq_data = []
# for i in range(1,length(sequences))
#     push!(seq_data, (string(i), sequences[i]))
# end

# Test MUSCLE
# seq_data = [("Plasmid_1:_Green_Fluorescent_Protein", "GATTATGTACAGTAAAGAACTATATTTTTCAAAGATGACGTGAAC"), ("Plasmid_2:_Red_Fluorescent_Protein",
# "TACATCATGGCATAACCGTAAGTAGTGACTTGGACAAACAAGAAC"), ("Plasmid_3:_Cyan_Fluorescent_Protein", "TCCATCGCTAACACTTGTCACTACTTTCGGTTATGGTGTTCAATG"), ("Plasmid_4:_Blue_Fluorescent_Protein:",
# "ATTCTTGTACACAAATTGGAATACAACTATAACTCACACAATGTA")]
# #
# print(muscle.align(seq_data, "isaiah_bryant@brown.edu"))
# f = open("/Users/ibryant/research/ptb/output/muscle_align.txt", "w")
# write(f, muscle.align(seq_data, "isaiah_bryant@brown.edu"))
# close(f)

#Test cipres
username = "ibryant"
pass = "cipresrest"
appid = "ASAP3-ACDBCA403D074E33887D26BAD8C5CA5F"

tree = cipres.build_tree("../data/fake_fasta.fasta", username, pass, appid; validate=false)
println(tree)
# headers = Dict()
# headers["cipres-appkey"] = appid
# print(get("https://$username:$pass@cipresrest.sdsc.edu/cipresrest/v1/job/ibryant", headers, []; basic_authorization=true))
