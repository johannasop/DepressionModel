Base.@kwdef struct Optimalparams
    prev_12month::Float64 = 0.075
    prev_15to65::Float64 = 0.25

    h::Float64 = 0.37
    c::Float64 = 0.0
    e::Float64 = 0.63

    increased_parents_30::Float64 = 0.30 #Achtung: Ergebnis aus Funktion muss dann in Kalibierung durch 10 geteilt werden
    increased_friends_4::Float64 = 4.59
    increased_ac_4::Float64 = 2.18
    increased_spouse_4::Float64 = 1.5
    
    dep_episode_one_more::Float64 = 0.50
    dep_episode_two_more::Float64 = 0.75
    dep_episode_three_more::Float64 = 0.90
end

Base.@kwdef struct Optimalrates

    prev::Float64 = 0.075
    rate_parents::Float64 = 0.26
    rate_friends::Float64=0.32
    rate_ac::Float64=0.16
    rate_spouse::Float64=0.32
    rate_child::Float64=0.24
    h::Float64 = 0.35

end
Base.@kwdef struct Optimalrr

    prev::Float64 = 0.075
    rr_par::Float64 = 2.38
    rr_fr::Float64 = 4.59
    rr_ac::Float64 = 1.5
    rr_sp::Float64 = 1.7
    rr_ch::Float64 = 2.5
    h::Float64 = 0.35
end

function evaluationparams(sim, rr_parents_30, increasedrisk_friends, increasedrisk_ac, increasedrisk_spouse)
    #Evaluation aller belegten Parameter
    o = Optimalparams()
    h, c, e = heritability_calculations(sim)
    perc_one, perc_two, perc_three = depressive_episode_analytics(sim)

    return ((abs(deprisk_life_15to65(sim) -o.prev_15to65)*10 + abs(h - o.h) + abs(e - o.e) + abs(c - o.c) + abs(rr_parents_30/10- o.increased_parents_30) + abs(log(increasedrisk_friends)- o.increased_friends_4) + abs(log(increasedrisk_ac) - o.increased_ac_4) + abs(log(increasedrisk_spouse)- o.increased_spouse_4)) + abs(perc_one - o.dep_episode_one_more) + abs(perc_two - o.dep_episode_two_more)+ abs(perc_three - o.dep_episode_three_more))/11


end

function evaluationrr(sim)
    #Evaluation der Risk Ratios
    rr_par, rr_fr, rr_ac, rr_sp, rr_ch = toriskratio(sim) 

    o = Optimalrr()
    h, c, e = heritability_calculations(sim)
    #meansquaredistance
    return ((o.prev - ratedep_12month(sim))^2 + (o.rr_par - rr_par)^2 + (o.rr_fr - rr_fr)^2 + (o.rr_ac - rr_ac)^2 + (o.h - h)^2) /5
end

function evaluationrates(sim)
    #Evaluation der Raten
    o = Optimalrates()
    h, c, e = heritability_calculations(sim)
    return ((o.prev - ratedep_12month(sim))^2 + (o.rate_parents-ratedep_parents_12month(sim))^2 + (o.rate_friends - ratedep_friends_12month(sim))^2 + (o.rate_ac-ratedep_ac_12month(sim))^2 + (o.h - h)^2)/5

end



function eval_params_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, n)
    meanfit = 0.0

    for i=1:n
        new_paras.seed = 0#rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        results = run_sim(sim, new_paras)
        meanfit = meanfit + evaluationparams(sim, results.rr_parents_30, results.incr4_fr, results.incr4_ac, results.incr4_sp)

    end

    return meanfit/n
end





function eval_rr_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = 0#rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, new_paras)

        meanfit = meanfit + evaluationrr(sim)
    end

    return meanfit/5
end

function eval_rates_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = 0#rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, new_paras)

        meanfit = meanfit + evaluationrates(sim)
    end

    return meanfit/5
end


#systematische Variation von Parameterwerten
function sensi!()

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    seeds = [12, 30, 42, 50, 74]
    parameters_par = [0.01, 0.05, 0.1, 0.5, 0.9]
    parameters_fr = [0.01, 0.05, 0.1, 0.5, 0.9]
    nodenames = ["seed=12", " ", " ", " ", " ", " ",  "seed=30"," ", " ", " ", " ", " ", "seed=42", " ", " ", " ", " ", " ", "seed=50", " ", " ", " ", " ", " ", "seed=74", " ", " ", " ", " ", " "]

    df= DataFrame([name => [] for name in nodenames], makeunique = true)
    placeholder = Vector{Float64}(undef, 0)
    

    for f in parameters_fr
        for p in parameters_par
            for s in seeds
                    para = Parameters(rate_friends = f, rate_parents = p, seed = s)
                    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
                    results= run_sim(sim, para)
                    push!(placeholder, ratedep_12month(sim), ratedep_parents_12month(sim), ratedep_friends_12month(sim), ratedep_ac_12month(sim), ratedep_child_12month(sim), ratedep_spouse_12month(sim))
            end
            push!(df, placeholder)
            placeholder = Vector{Float64}(undef, 0)
        end
    end
    CSV.write("Sensibilitätsanalyse.csv", df)

end

function qual_sensi()
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    parents = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5]
    friends = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5]
    h = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5]
    

    df_par_fr= DataFrame(par = [], fr = [], her = [], qual = [])
    df_par_h = DataFrame(par = [], fr = [], her = [], qual = [])
    df_h_fr = DataFrame(par = [], fr = [], her = [], qual = [])
    
    for i in eachindex(parents)
        for x in eachindex(friends)

            paras = Parameters(rate_parents = parents[i], rate_friends= friends[x], h = 0)

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            results = run_sim(sim, paras)
            push!(df_par_fr, [parents[i] friends[x] 0.0 evaluationrates(sim)])        
        end
    end
    for i in eachindex(parents)
        for x in eachindex(h)
            paras = Parameters(rate_parents = parents[i], h= h[x], rate_friends = 0)

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            results = run_sim(sim, paras)
            push!(df_par_h, [parents[i] 0.0 h[x] evaluationrates(sim)])    
        end
    end
    for i in eachindex(h)
        for x in eachindex(friends)
            paras = Parameters(h = h[i], rate_friends= friends[x], rate_parents = 0)

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            results = run_sim(sim, paras)
            push!(df_h_fr, [0.0 friends[x] h[i] evaluationrates(sim)])    
        end
    end
    println("Sensi fertig")
    return df_par_fr, df_par_h, df_h_fr 
end


#einfache Approximation an optimale Werte
#redundant noch ändern
mutable struct Paraqualityrr  

    parameters::Parameters
    quality::Float64

end
mutable struct Paraqualityrates

    parameters::Parameters
    quality::Float64

end


function randpara()

    return Parameters(prev = rand(0.0:3.0), rate_parents= rand(0.0:3.0), rate_friends=rand(0.0:3.0), rate_ac = rand(0.0:3.0), rate_child = rand(0.0:3.0), rate_spouse = rand(0.0:3.0), h= rand(),  b=rand(0.0:10.0), homophily_friends=rand(), homophily_spouse=rand(), homophily_ac=rand())

end

function limit(mi, v, ma)
   return min(ma, max(mi, v))
end

function paraplusnorm(paras)
    
    new_paras = Parameters(prev=limit(0, paras.prev + rand(Normal(0,1.0)), 10), rate_parents = limit(0, paras.rate_parents + rand(Normal(0,1.0)), 10), rate_friends = limit(0, paras.rate_friends + rand(Normal(0,1.0)), 10), rate_ac = limit(0, paras.rate_ac + rand(Normal(0,1.0)), 10), rate_child = limit(0, paras.rate_child + rand(Normal(0,1.0)), 10), rate_spouse = limit(0, paras.rate_spouse + rand(Normal(0,1.0)), 10), h = limit(0, paras.h + rand(Normal(0,0.1)), 1), mw_h = limit(-10, paras.mw_h + rand(Normal(0, 1.0)), 10), b = limit(0, paras.b + rand(Normal(0,1.0)), 5), homophily_ac = limit(0, paras.homophily_ac + rand(Normal(0, 0.1)), 1), homophily_friends = limit(0, paras.homophily_friends + rand(Normal(0, 0.1)), 1) , homophily_spouse = limit(0, paras.homophily_spouse + rand(Normal(0, 0.1)), 1))

    return new_paras
end


function approximation_params!(steps, npoints=600) 

    pq_rates = Paraqualityrates[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rates_new_paras = eval_params_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, 5)

        push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))
    end
    
    for i=1:steps
        sort!(pq_rates, by=p->p.quality)

        println(pq_rates[1].quality)
        println(pq_rates[2].quality)
        println(pq_rates[3].quality)
        println(last(pq_rates).quality)


        for i=1:(npoints ÷ 2)
            pop!(pq_rates)
        end


        for i=1:(npoints ÷ 2)
            new_paras_rates = paraplusnorm(pq_rates[trunc(Int64, rand(truncated(Normal(1, npoints/6); lower = 1, upper = npoints ÷ 2
            )))].parameters)

            qual_rates_new_paras = eval_params_multipleseeds(new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, 5)

            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end

        println("step $i")

    end 

    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution_rates(pq_rates) 
end

function approximation_params_big!(steps, npoints=600) 

    pq_rates = Paraqualityrates[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rates_new_paras = eval_params_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, 1)

        push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))
    end
    
    for i=1:steps
        sort!(pq_rates, by=p->p.quality)

        println(pq_rates[1].quality)
        println(pq_rates[2].quality)
        println(pq_rates[3].quality)
        println(last(pq_rates).quality)


        for i=1:(npoints ÷ 2)
            pop!(pq_rates)
        end


        for i=1:(npoints ÷ 2)
            new_paras_rates = paraplusnorm(pq_rates[trunc(Int64, rand(truncated(Normal(1, npoints/6); lower = 1, upper = npoints ÷ 2
            )))].parameters)

            qual_rates_new_paras = eval_params_multipleseeds(new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, 1)

            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end

        println("step $i")

    end 

    for i in eachindex(pq_rates)

        pq_rates[i].quality = eval_params_multipleseeds(pq_rates[i].parameters, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, 5)
        print(",")

    end

    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution_rates(pq_rates) 
end


function approximation_rates(steps, npoints=600) 

    pq_rates = Paraqualityrates[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rates_new_paras = eval_rates_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

        push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))
    end
    
    for i=1:steps
        sort!(pq_rates, by=p->p.quality)

        push!(quality_array, pq_rates[1].quality)
        println(pq_rates[1].quality)
        println(pq_rates[2].quality)
        println(pq_rates[3].quality)
        println(last(pq_rates).quality)


        for i=1:(npoints ÷ 2)
            pop!(pq_rates)
        end


        for i=1:(npoints ÷ 2)
            new_paras_rates = paraplusnorm(pq_rates[trunc(Int64, rand(truncated(Normal(1, npoints/6); lower = 1, upper = npoints ÷ 2
            )))].parameters)

            qual_rates_new_paras = eval_rates_multipleseeds(new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end

        println("step $i")

    end 

    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution_rates(pq_rates) 

    return quality_array

end

function calibration_abcde!()
    
    data = Optimalparams()
    #priors = Product([Uniform(0,10) for i=1:10]), [Uniform(0,1) for i=1:4], [Uniform(-10, 10) for i = 1:2]

    ϵ = 0.1

    priors = Product([Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,10), Uniform(0,1), Uniform(0,1), Uniform(0,1), Uniform(0,1), Uniform(0,10), Uniform(0,1), Uniform(0,1)]) 

    r1 = abcdesmc!(priors, dist!, ϵ , data, nparticles=130, nsims_max = 100000, parallel = true)

    # posterior_prev = [t[1] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_par = [t[2] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_fr = [t[3] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_fr_healthy = [t[4] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_ac = [t[5] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_ch = [t[6] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_sp = [t[7] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_hom_fr = [t[8] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_hom_sp = [t[9] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_hom_ac = [t[10] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_h = [t[11] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_lambda = [t[12] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_scaling = [t[13] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_mw = [t[14] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_mw = [t[15] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_mw = [t[16] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_mw = [t[17] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_mw = [t[18] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_mw = [t[19] for t in r1.P[r1.Wns .> 0.0]]
    # posterior_mw = [t[20] for t in r1.P[r1.Wns .> 0.0]]

    evidence = exp(r1.logZ)
    blobs = r1.blobs[r1.Wns .> 0.0]

    present_solution_abcde!(r1)
    println(r1.P)


    # Plots.histogram(posterior_prev, normed=true, bins = 10, labels = "posterior prev", xrange = (0,10))
    # Plots.histogram(posterior_par, normed=true, bins = 10, labels = "posterior par", xrange = (0,10))
    # Plots.histogram(posterior_fr, normed=true, bins = 10, labels = "posterior fr", xrange = (0,10))
    # Plots.histogram(posterior_fr_healthy, normed=true, bins = 10, labels = "posterior fr healthy", xrange = (0,10))
    # Plots.histogram(posterior_ac, normed=true, bins = 10, labels = "posterior ac", xrange = (0,10))
    # Plots.histogram(posterior_ch, normed=true, bins = 10, labels = "posterior ch", xrange = (0,10))
    # Plots.histogram(posterior_sp, normed=true, bins = 10, labels = "posterior spouse", xrange = (0,10))
    # Plots.histogram(posterior_hom_fr, normed=true, bins = 10, labels = "posterior hom_fr", xrange = (0,1))
    # Plots.histogram(posterior_hom_sp, normed=true, bins = 10, labels = "posterior hom_sp", xrange = (0,1))
    # Plots.histogram(posterior_hom_ac, normed=true, bins = 10, labels = "posterior hom_ac", xrange = (0,1))
    # Plots.histogram(posterior_h, normed=true, bins = 10, labels = "posterior h", xrange = (0,1))
    # Plots.histogram(posterior_lambda, normed=true, bins = 10, labels = "posterior lambda", xrange = (0,1))
    # Plots.histogram(posterior_scaling, normed=true, bins = 10, labels = "posterior scaling", xrange = (0,10))
    # Plots.histogram(posterior_mw, normed=true, bins = 10, labels = "posterior mw", xrange = (0,1))

    
end

function dist!(p, data) 
    results, h, c, e, life, prev, perc_one, perc_two, perc_three = model(p)
    results_vector = [prev, life, results.rr_parents_30/10, log(results.incr4_fr), log(results.incr4_ac), log(results.incr4_sp), perc_one, perc_two, perc_three, h, c, e]
    data_vector = [data.prev_12month, data.prev_15to65, data.increased_parents_30, log(data.increased_friends_4), log(data.increased_ac_4), log(data.increased_spouse_4), data.dep_episode_one_more, data.dep_episode_two_more, data.dep_episode_three_more, data.h, data.c, data.e]

    Distances.euclidean(results_vector, data_vector), nothing
 end

function model(r)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    paras = Parameters(prev = r[1], rate_parents = r[2], rate_friends = r[3], rate_friends_healthy = r[4], rate_ac = r[5], rate_child = r[6], rate_spouse = r[7], rate_spouse_healthy = r[8], homophily_friends=r[9], homophily_spouse=r[10], homophily_ac=r[11],  lambda = r[12], scaling = r[13], w_mean = r[14], h_expo=r[15])
    
    sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

    results = run_sim(sim, paras)
    h, c, e = heritability_calculations(sim)
    life = deprisk_life_15to65(sim)
    prev = ratedep_12month(sim)

    perc_one, perc_two, perc_three = depressive_episode_analytics(sim)
    return results, h, c, e, life, prev, perc_one, perc_two, perc_three
end

function present_solution_abcde!(r)

    best = []

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

    o = Optimalparams()

    for i=1:100
        push!(best, sample(r.P , Weights(r.Wns)))
    end
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
            results, h, c, e, life, prev, perc_one, perc_two, perc_three = model(paras)
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


    println("Standardabweichungen der Parameter: ")
    println("prev: ", std([t[1] for t in r.P[r.Wns .> 0.0]]))
    println("rate parents: ", std([t[2] for t in r.P[r.Wns .> 0.0]]))
    println("rate friends: ", std([t[3] for t in r.P[r.Wns .> 0.0]]))
    println("rate friends healthy: ", std([t[4] for t in r.P[r.Wns .> 0.0]]))
    println("rate ac: ", std([t[5] for t in r.P[r.Wns .> 0.0]]))
    println("rate child: ", std([t[6] for t in r.P[r.Wns .> 0.0]]))
    println("rate spouse: ", std([t[7] for t in r.P[r.Wns .> 0.0]]))
    println("rate spouse healthy: ", std([t[8] for t in r.P[r.Wns .> 0.0]]))
    println("homophily friends: ", std([t[9] for t in r.P[r.Wns .> 0.0]]))
    println("homophily spouse: ", std([t[10] for t in r.P[r.Wns .> 0.0]]))
    println("homophily ac: ", std([t[11] for t in r.P[r.Wns .> 0.0]]))
    println("lambda: ", std([t[12] for t in r.P[r.Wns .> 0.0]]))
    println("scaling: ", std([t[13] for t in r.P[r.Wns .> 0.0]]))
    println("w_mean: ", std([t[14] for t in r.P[r.Wns .> 0.0]]))
    println("h expo: ", std([t[15] for t in r.P[r.Wns .> 0.0]]))

    
  
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

function optimization_current_para(steps, npoints=600)
    pq_rates = Paraqualityrates[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    new_paras = Parameters()
    qual_rates_new_paras = eval_rates_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 
    push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))

    for i=2:npoints
        new_rand_paras = paraplusnorm(new_paras)
        qual_rates_new_paras = eval_rates_multipleseeds(new_rand_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        push!(pq_rates, Paraqualityrates(new_rand_paras, qual_rates_new_paras))
        print(".")
    end
    for i=1:steps
        sort!(pq_rates, by=p->p.quality)

        push!(quality_array, pq_rates[1].quality)
        println(pq_rates[1].quality)
        println(pq_rates[2].quality)
        println(pq_rates[3].quality)
        println(last(pq_rates).quality)


        for i=1:(npoints ÷ 2)
            pop!(pq_rates)
        end


        for i=1:(npoints ÷ 2)
            new_paras_rates = paraplusnorm(pq_rates[trunc(Int64, rand(truncated(Normal(0, npoints/6); lower = 1, upper = npoints ÷ 2
            )))].parameters)

            qual_rates_new_paras = eval_rates_multipleseeds(new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end

        println("step $i")

    end 

    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution_rates(pq_rates)

    return quality_array

end
function approximation_rr(steps, npoints=600)
    pq_rr = Paraqualityrr[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rr_new_paras = eval_rr_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

        push!(pq_rr, Paraqualityrr(new_paras, qual_rr_new_paras)) 
    end
    
    for i=1:steps
        sort!(pq_rr, by=p->p.quality)

        push!(quality_array, pq_rr[1].quality)

        println(pq_rr[1].quality)
        println(pq_rr[2].quality)
        println(pq_rr[3].quality)


        for i=1:(npoints ÷ 2)
            pop!(pq_rr)
        end

        for i=1:(npoints ÷ 2)
            new_paras_rr = paraplusnorm(pq_rr[trunc(Int64, rand(truncated(Normal(0,100); lower = 1 , upper = npoints ÷ 2
            )))].parameters)

            qual_rr_new_paras = eval_rr_multipleseeds(new_paras_rr, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

            push!(pq_rr, Paraqualityrr(new_paras_rr, qual_rr_new_paras)) 
        end
        println("step $i")

    end 

    sort!(pq_rr, by=p->p.quality)

    present_optimalsolution_rr(pq_rr)

    return quality_array

end
function present_optimal_solution(pq_rates)

    for i = 1:3
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
        sim= setup_sim(pq_rates[i].parameters, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

        results = run_sim(sim, new_paras)
        println("Die optimalen Parameter sind Folgende: ", pq_rates[i].parameters)

        printpara!(sim, results)
    end

end
function present_optimalsolution_rates(pq_rates)

    for i=1:3
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

        sim= setup_sim(pq_rates[i].parameters, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        results= run_sim(sim, pq_rates[i].parameters)

        println("die Parameter (rates) sind Folgende: ", pq_rates[i].parameters)
        printpara!(sim, results)
    end
end

function quality_function_para(x)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    parameter_field = collect(0.01:0.01:1)
    quality_array = Float64[]
    lowest =  1.0
    lowest_index = 0
    

    if x == "parent"
        for i in eachindex(parameter_field)
            println(i)
            para = Parameters(rate_parents=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "friends"
        for i in eachindex(parameter_field)
            para = Parameters(rate_friends=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "spouse"
        for i in eachindex(parameter_field)
            para = Parameters(rate_spouse=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "child"
        for i in eachindex(parameter_field)
            para = Parameters(rate_child=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "ac"
        for i in eachindex(parameter_field)
            para = Parameters(rate_ac=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "prev"
        for i in eachindex(parameter_field)
            para = Parameters(prev=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "h"
        for i in eachindex(parameter_field)
            para = Parameters(h=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    end

    return quality_array, parameter_field, lowest_index
end

function present_optimalsolution_rr(pq_rr)

    for i=1:3
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
        sim = setup_sim(pq_rr[i].parameters,d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        results= 0run_sim(sim, pq_rr[i].parameters)

        println("die Parameter (RR) sind Folgende: ", pq_rr[i].parameters)
        printpara!(sim, results)
    end
end




