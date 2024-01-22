Base.@kwdef mutable struct Optimalparams
    prev_12month::Float64 = 7.5
    prev_15to65::Float64 = 25.0

    h::Float64 = 0.37
    increased_parents_30::Float64 = 3
    increased_friends_4::Float64 = 3.59
    increased_ac_4::Float64 = 1.18
    increased_spouse_4::Float64 = 0.5
    
end

Base.@kwdef mutable struct Optimalrates

    prev::Float64 = 0.075
    rate_parents::Float64 = 0.26
    rate_friends::Float64=0.32
    rate_ac::Float64=0.16
    rate_spouse::Float64=0.32
    rate_child::Float64=0.24
    h::Float64 = 0.35

end
Base.@kwdef mutable struct Optimalrr

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

    return ((o.prev_12month - (ratedep_12month(sim)*100))^2 + (o.prev_15to65 - (deprisk_life_15to65(sim)*100))^2 + (o.h - h)^2 + (o.increased_parents_30 - rr_parents_30)^2 + (o.increased_friends_4 - increasedrisk_friends)^2 + (o.increased_ac_4 - increasedrisk_ac)^2 + (o.increased_spouse_4 - increasedrisk_spouse)^2 )/7

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



function eval_params_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = 0#rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        results = run_sim(sim, new_paras)
        meanfit = meanfit + evaluationparams(sim, results.rr_parents_30, results.increased_risk_friends_4, results.increased_risk_ac_4, results.increased_risk_spouse_4)

    end

    return meanfit/5
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

    return Parameters(prev = rand(0.0:3.0), rate_parents= rand(0.0:3.0), rate_friends=rand(0.0:3.0), rate_ac = rand(0.0:3.0), rate_child = rand(0.0:3.0), rate_spouse = rand(0.0:3.0), h= rand(), b=rand(0.0:10.0))

end

function limit(mi, v, ma)
   return min(ma, max(mi, v))
end

function paraplusnorm(paras)
    
    new_paras = Parameters(prev=limit(0, paras.prev + rand(Normal(0,1.0)), 3), rate_parents = limit(0, paras.rate_parents + rand(Normal(0,1.0)), 3), rate_friends = limit(0, paras.rate_friends + rand(Normal(0,1.0)), 3), rate_ac = limit(0, paras.rate_ac + rand(Normal(0,1.0)), 3), rate_child = limit(0, paras.rate_child + rand(Normal(0,1.0)), 3), rate_spouse = limit(0, paras.rate_spouse + rand(Normal(0,1.0)), 3), h = limit(0, paras.h + rand(Normal(0,0.1)), 1), b = limit(0, paras.b + rand(Normal(0,1.0)), 5))

    return new_paras
end
function approximation_params(steps, npoints=600) 

    pq_rates = Paraqualityrates[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rates_new_paras = eval_params_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

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

            qual_rates_new_paras = eval_params_multipleseeds(new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end

        println("step $i")

    end 

    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution_rates(pq_rates) 

    return quality_array

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




