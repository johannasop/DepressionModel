
function evaluationrr(sim, data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch)
    #Evaluation der Risk Ratios
    rr_par, rr_fr, rr_ac, rr_sp, rr_ch = toriskratio(sim) 

    #meansquaredistance
    return ((data_rr_par - rr_par)^2 + (data_rr_fr - rr_fr)^2 ) /2
end

function evaluationrates(sim, data_prev, data_rate_parents, data_rate_friends, data_rate_ac, data_rate_children, data_rate_spouse)
    #Evaluation der Raten
    return ((data_prev - ratedep(sim))^2 + (data_rate_parents-ratedep_parents(sim))^2 + (data_rate_friends - ratedep_friends(sim))^2 + (data_rate_ac-ratedep_ac(sim))^2 + (data_rate_spouse - ratedep_spouse(sim))^2 )/5

end




function eval_rr_multipleseeds(data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch, new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, 50, new_paras)

        meanfit = meanfit + evaluationrr(sim, data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch)
    end

    return meanfit/5
end

function eval_rates_multipleseeds(data_prev, data_rate_par, data_rate_fr, data_rate_ac, data_rate_sp, data_rate_ch, new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, 50, new_paras)

        meanfit = meanfit + evaluationrates(sim, data_prev, data_rate_par, data_rate_fr, data_rate_ac, data_rate_sp, data_rate_ch)
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
    cl = 1
    cn = 1

    for f in parameters_fr
        for p in parameters_par
            for s in seeds
                    para = Parameters(rate_friends = f, rate_parents = p, seed = s)
                    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
                    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, 50, para)
                    push!(placeholder, ratedep(sim), ratedep_parents(sim), ratedep_friends(sim), ratedep_ac(sim), ratedep_child(sim), ratedep_spouse(sim))
            end
            push!(df, placeholder)
            placeholder = Vector{Float64}(undef, 0)
        end
    end
    CSV.write("Sensibilitätsanalyse.csv", df)

end




#einfache Approximation an optimale Werte

mutable struct Paraqualityrr  

    parameters::Parameters
    quality::Float64

end
mutable struct Paraqualityrates

    parameters::Parameters
    quality::Float64

end

function randpara()

    return Parameters(prev = rand(), rate_parents= rand(), rate_friends=rand(), rate_ac = rand(), rate_child = rand(), rate_spouse = rand(), h= rand(), b=0.1)

end

function limit(mi, v, ma)
   return min(ma, max(mi, v))
end

function paraplusnorm(paras)
    
    new_paras = Parameters(prev=limit(0, paras.prev + rand(Normal(0,0.01)), 1), rate_parents = limit(0, paras.rate_parents + rand(Normal(0,0.01)), 1), rate_friends = limit(0, paras.rate_friends + rand(Normal(0,0.01)), 1), rate_ac = limit(0, paras.rate_ac + rand(Normal(0,0.01)), 1), rate_child = limit(0, paras.rate_child + rand(Normal(0,0.01)), 1), rate_spouse = limit(0, paras.rate_spouse + rand(Normal(0,0.01)), 1), h = limit(0, paras.h + rand(Normal(0,0.01)), 1))

    return new_paras
end

function approximation(steps, npoints=600) 

    pq_rates = Paraqualityrates[]
    pq_rr = Paraqualityrr[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rr_new_paras = eval_rr_multipleseeds(2.5, 3.5, 1.2, 1.2, 1.5, new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        qual_rates_new_paras = eval_rates_multipleseeds(0.08, 0.26, 0.32, 0.12, 0.12, 0.26, new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

        push!(pq_rr, Paraqualityrr(new_paras, qual_rr_new_paras)) 
        push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))
    end
    
    println()

    for i=1:steps
        sort!(pq_rr, by=p->p.quality)
        sort!(pq_rates, by=p->p.quality)

        push!(quality_array, pq_rates[1].quality)
        println(pq_rates[1].quality)
        println(pq_rates[2].quality)
        println(pq_rates[3].quality)

        println(pq_rr[1].quality)
        println(pq_rr[2].quality)
        println(pq_rr[3].quality)

        
        # das zuerst, sonst werden die neuen Punkte direkt wieder entfernt
        for i=1:(npoints ÷ 2)
            pop!(pq_rr)
            pop!(pq_rates)
        end

        for i=1:(npoints ÷ 2)
            new_paras_rates = paraplusnorm(pq_rates[rand(1:(npoints÷6))].parameters)
            new_paras_rr = paraplusnorm(pq_rr[rand(1:(npoints÷6))].parameters)

            qual_rr_new_paras = eval_rr_multipleseeds(2.5, 3.5, 1.2, 1.2, 1.2, new_paras_rr, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            qual_rates_new_paras = eval_rates_multipleseeds(0.08, 0.26, 0.32, 0.12, 0.12, 0.26, new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

            push!(pq_rr, Paraqualityrr(new_paras_rr, qual_rr_new_paras)) 
            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end
        println("step $i")

    end 

    sort!(pq_rr, by=p->p.quality)
    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution(pq_rr, pq_rates)

    return quality_array

end


function present_optimalsolution(pq_rr, pq_rates)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    sim = setup_sim(pq_rr[1].parameters,d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    run_sim(sim, 50, pq_rr[1].parameters)

    sim2= setup_sim(pq_rates[1].parameters, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    run_sim(sim2, 50, pq_rates[1].parameters)

    print("die optimalen Parameter (RR) sind Folgende: ", pq_rr[1].parameters, "\n")
    printpara!(sim)
    print("die optimalen Parameter (rates) sind Folgende: ", pq_rates[1].parameters, "\n")
    printpara!(sim2)
end

function printpara!(sim)
    rr_par, rr_fr, rr_ac, rr_sp, rr_ch = toriskratio(sim)
    print( "\n prev ", ratedep(sim) )
    print( "\n prev parents ", ratedep_parents(sim) )
    print( "\n prev friends ", ratedep_friends(sim) )
    print( "\n prev ac ", ratedep_ac(sim) )
    print( "\n prev spouse ", ratedep_spouse(sim) )
    print( "\n prev children ", ratedep_child(sim) )
    print( "\n avg risk ", averagerisk(sim) , "\n")

    print( "\n rr parents ", rr_par)
    print( "\n rr fr ", rr_fr)
    #print( "\n rr ac ", rr_ac)
    print( "\n rr sp ", rr_sp)
    print( "\n rr ch ", rr_ch, "\n")
end


