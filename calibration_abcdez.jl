using Distances
using Distributions
using StatsBase
using ABCdeZ


function present_solution_abcde!(r)

    prev_12 = Float64[]
    prev_1565 = Float64[]
    p_one = Float64[]
    p_two = Float64[]
    p_three = Float64[]
    incr_par = Float64[]
    incr_fr = Float64[]
    incr_ac = Float64[]
    incr_spouse = Float64[]
    h_array = Float64[]
    c_array = Float64[]
    e_array = Float64[]
    dist = Float64[]

    o = EmpiricalParams()
    
    # *** sample from posterior and manually select param combi with best result
    
    best =  sample(r.P , Weights(r.Wns), 100)
    
    for paras in best
        prev_12_single = Float64[]
        prev_1565_single = Float64[]
        p_one_single = Float64[]
        p_two_single = Float64[]
        p_three_single = Float64[]
        incr_par_single = Float64[]
        incr_fr_single = Float64[]
        incr_ac_single = Float64[]
        incr_spouse_single = Float64[]
        h_array_single = Float64[]
        c_array_single = Float64[]
        e_array_single = Float64[]
        dist_single = Float64[]

        for i=1:10
            (;results, h, c, e, life, prev, perc_one, perc_two, perc_three) = model(paras)
            distance, nothing = dist!(paras, o)
            push!(prev_12_single, prev)
            push!(prev_1565_single, life)
            push!(p_one_single, perc_one)
            push!(p_two_single, perc_two)
            push!(p_three_single, perc_three)
            push!(incr_par_single, results.rr_parents_30/10)
            push!(incr_fr_single, results.incr4_fr)
            push!(incr_ac_single, results.incr4_ac)
            push!(incr_spouse_single, results.incr4_sp)
            push!(h_array_single, h)
            push!(c_array_single, c)
            push!(e_array_single, e)
            push!(dist_single, distance)
        end

        push!(prev_12, mean(prev_12_single))
        push!(prev_1565, mean(prev_1565_single))
        push!(p_one, mean(p_one_single))
        push!(p_two, mean(p_two_single))
        push!(p_three, mean(p_three_single))
        push!(incr_par, mean(incr_par_single))
        push!(incr_fr, mean(incr_fr_single))
        push!(incr_ac, mean(incr_ac_single))
        push!(incr_spouse, mean(incr_spouse_single))
        push!(h_array, mean(h_array_single))
        push!(c_array, mean(c_array_single))
        push!(e_array, mean(e_array_single))
        push!(dist, mean(dist_single))
    end
    
    particles = r.P[r.Wns .> 0.0]

    println("Standardabweichungen der Parameter: ")
    println("prev: ", std([t[1] for t in particles]))
    println("rate parents: ", std([t[2] for t in particles]))
    println("rate friends: ", std([t[3] for t in particles]))
    println("rate friends healthy: ", std([t[4] for t in particles]))
    println("rate ac: ", std([t[5] for t in particles]))
    println("rate child: ", std([t[6] for t in particles]))
    println("rate spouse: ", std([t[7] for t in particles]))
    println("rate spouse healthy: ", std([t[8] for t in particles]))
    println("homophily friends: ", std([t[9] for t in particles]))
    println("homophily spouse: ", std([t[10] for t in particles]))
    println("homophily ac: ", std([t[11] for t in particles]))
    println("lambda: ", std([t[12] for t in particles]))
    println("scaling: ", std([t[13] for t in particles]))
    println("w_mean: ", std([t[14] for t in particles]))
    println("h expo: ", std([t[15] for t in particles]))

    
  
    println(" ")
    println("Mittelwerte der Kalibrierungsergebnisse: ")
    println("prev (12 months): ", mean(prev_12), " Standardabweichung: ", std(prev_12))
    println("risk of depression between 15 and 65: ", mean(prev_1565), " Standardabweichung: ",std(prev_1565))
    println(" ")
    println("risk for another episode, if person has at least one depressive episode: ", mean(p_one), " Standardabweichung: ",std(p_one))
    println("risk for another episode, if person has at least two depressive episodes: ", mean(p_two), " Standardabweichung: ",std(p_two))
    println("risk for another episode, if person has at least three depressive episodes: ", mean(p_three), " Standardabweichung: ",std(p_three))
    println(" ")
    println("risk ratio parents 30 years later: ", mean(incr_par)*10, " Standardabweichung: ",std(incr_par))
    println("increased risk if friend is depressed 4 years later: ", mean(incr_fr) - 1, " Standardabweichung: ",std(incr_fr))
    println("increased risk if ac is depressed 4 years later: ", mean(incr_ac)- 1, " Standardabweichung: ",std(incr_ac))
    println("increased risk if spouse is depressed 4 years later: ", mean(incr_spouse)- 1, " Standardabweichung: ",std(incr_spouse))
    println(" ")
    println("Heritabilitätsschätzer")
    println("h: ", mean(h_array), " Standardabweichung: ", std(h_array))
    println("c: ", mean(c_array), " Standardabweichung: ", std(c_array))
    println("e: ", mean(e_array), " Standardabweichung: ", std(e_array))
    println(" ")
    #println("Korrelation der Eigenvektorzentralität mit der Anzahl depressiver Episoden: ", eigen_centrality(sim))
    
    
    mindistance, index = findmin(dist)

    # while mindistance == 1000 || mindistance === NaN
    #     mindistance, index = findmin(dist)

    #     if mindistance === NaN
    #         dist[index] = 1000
    #     end
    # end
    println("parameters with lowest distance: ", best[index])
    println("minimal distance is: ", mindistance)

end


function dist!(p, data) 
    (;results, h, c, e, life, prev, perc_one, perc_two, perc_three) = model(p)
    results_vector = [prev, life, results.rr_parents_30/10, log(results.incr4_fr), log(results.incr4_ac), log(results.incr4_sp), perc_one, perc_two, perc_three, h, c, e]
    data_vector = [data.prev_12month, data.prev_15to65, data.increased_parents_30, log(data.increased_friends_4), log(data.increased_ac_4), log(data.increased_spouse_4), data.dep_episode_one_more, data.dep_episode_two_more, data.dep_episode_three_more, data.h, data.c, data.e]

    Distances.euclidean(results_vector, data_vector), nothing
end
 
 
function model(r)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    paras = Parameters(prev = r[1], rate_parents = r[2], rate_friends = r[3], rate_friends_healthy = r[4], rate_ac = r[5], rate_child = r[6], rate_spouse = r[7], rate_spouse_healthy = r[8], homophily_friends=r[9], homophily_spouse=r[10], homophily_ac=r[11],  lambda = r[12], scaling = r[13], w_mean = r[14], h_expo=r[15], rem_ther=r[16])
    
    sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

    results = run_sim(sim, paras)
    h, c, e = heritability_calculations(sim)
    life = deprisk_life_15to65(sim)
    prev = ratedep_12month(sim)

    perc_one, perc_two, perc_three = depressive_episode_analytics(sim)
    
    # return named tuple to catch typos
    return (;results, h, c, e, life, prev, perc_one, perc_two, perc_three)
end


function calibration_abcde!(data; nparticles=130, nsims_max=500000, parallel=true)
    ϵ = 0.1

    priors = Product([Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,1), Uniform(0,1), Uniform(0,1), Uniform(0,1), Uniform(0,10), Uniform(0,1), Uniform(0,1), Uniform(0,10)]) 

    abcdesmc!(priors, dist!, ϵ , data; nparticles, nsims_max, parallel)
end
