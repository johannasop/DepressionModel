

function evaluationrr(sim, data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch)
    #Evaluation der Risk Ratios
    rr_par, rr_fr, rr_ac, rr_sp, rr_ch = toriskratio(sim) 

    #meansquaredistance
    return ((data_rr_par - rr_par)^2 + (data_rr_fr - rr_fr)^2 ) /2
end

function evaluationrates(sim)
    #Evaluation der Raten
    o = Optimalrates()
    return ((o.prev - ratedep(sim))^2 + (o.rate_parents-ratedep_parents(sim))^2 + (o.rate_friends - ratedep_friends(sim))^2 + (o.rate_ac-ratedep_ac(sim))^2 + (o.rate_child - ratedep_child(sim))^2 + (o.rate_spouse - ratedep_spouse(sim))^2 )/6

end






function eval_rr_multipleseeds(data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch, new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = 0#rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, new_paras, ther_restriction, fdbck_education, fdbck_income)

        meanfit = meanfit + evaluationrr(sim, data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch)
    end

    return meanfit/5
end

#for Schleife auf 1 gesetzt weil seed ja eh gleich bleibt
function eval_rates_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
    meanfit = 0.0

    for i=1:1
        new_paras.seed = 0#rand(1:100)
        sim = setup_sim(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, new_paras, ther_restriction, fdbck_education, fdbck_income)

        meanfit = meanfit + evaluationrates(sim)
    end

    #das geteilt durch fünf müsste hier eigentlich weg, aber für die Vergleichbarkeit lasse ich es erstmal drin
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
                    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, para, true, false, false)
                    push!(placeholder, ratedep(sim), ratedep_parents(sim), ratedep_friends(sim), ratedep_ac(sim), ratedep_child(sim), ratedep_spouse(sim))
            end
            push!(df, placeholder)
            placeholder = Vector{Float64}(undef, 0)
        end
    end
    CSV.write("Sensibilitätsanalyse.csv", df)

end

function qual_sensi!()
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    parents = [0.0, 0.02, 0.05, 0.1, 0.3, 0.5]
    friends = [0.0, 0.02, 0.05, 0.1, 0.3, 0.5]
    h = [0.0, 0.02, 0.05, 0.1, 0.3, 0.5]

    for i in eachindex(parents)
        qual_par_fr = Float64[]

        println("parents: ", parents[i])
        for x in eachindex(friends)

            paras = Parameters(rate_parents = parents[i], rate_friends= friends[x])

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, paras, true, false, false)

            push!(qual, evaluationrates(sim))
        end
        Plots.plot([qual], labels = "Qual: parents und friends")

    end
    for i in eachindex(parents)
        qual = Float64[]

        for x in eachindex(h)
            paras = Parameters(rate_parents = parents[i], h= h[x])

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, paras, true, false, false)

            push!(qual, evaluationrates(sim))
        end
        Plots.plot([qual], labels = "Qual: parents und h")

    end
    for i in eachindex(h)
        qual = Float64[]

        for x in eachindex(friends)
            paras = Parameters(h = h[i], rate_friends= friends[x])

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, paras, true, false, false)

            push!(qual, evaluationrates(sim))
        end
        Plots.plot([qual], labels = "Qual h und friends")

    end

    #hier dann nochmal mit umgekehrten Achsen
    for i in eachindex(friends)
        qual = Float64[]

        for x in eachindex(parents)
            paras = Parameters(rate_parents = parents[x], rate_friends= friends[i])

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, paras, true, false, false)

            push!(qual, evaluationrates(sim))
        end
        Plots.plot([qual], labels = "Qual: parents und friends")

    end
    for i in eachindex(h)
        qual = Float64[]

        for x in eachindex(parents)
            paras = Parameters(rate_parents = parents[x], h= h[i])

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, paras, true, false, false)

            push!(qual, evaluationrates(sim))
        end
        Plots.plot([qual], labels = "Qual: parents und h")

    end
    for i in eachindex(friends)
        qual = Float64[]

        for x in eachindex(h)
            paras = Parameters(h = h[x], rate_friends= friends[i])

            sim = setup_sim(paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
            depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, paras, true, false, false)

            push!(qual, evaluationrates(sim))
        end
        Plots.plot([qual], labels = "Qual h und friends")

    end
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
Base.@kwdef mutable struct Optimalrates

    prev::Float64 = 0.08
    rate_parents::Float64 = 0.24
    rate_friends::Float64=0.32
    rate_ac::Float64=0.12
    rate_spouse::Float64=0.32
    rate_child::Float64=0.24

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

#Achtung hier wird nicht mehr mit mehreren Seeds optimiert sondern Seed bleibt durch eval_rates_multipleseeds immer 0
function approximation_rates(steps, ther_restriction, fdbck_education, fdbck_income, npoints=600) 

    pq_rates = Paraqualityrates[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rates_new_paras = eval_rates_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education,fdbck_income)

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

            qual_rates_new_paras = eval_rates_multipleseeds(new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education,fdbck_income)

            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end

        println("step $i")

    end 

    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution_rates(pq_rates, ther_restriction, fdbck_education, fdbck_income)

    return quality_array

end
function optimization_current_para(steps, ther_restriction, fdbck_education, fdbck_income, npoints=600)
    pq_rates = Paraqualityrates[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    new_paras = Parameters()
    qual_rates_new_paras = eval_rates_multipleseeds(new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
    push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))

    for i=2:npoints
        new_rand_paras = paraplusnorm(new_paras)
        qual_rates_new_paras = eval_rates_multipleseeds(new_rand_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
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

            qual_rates_new_paras = eval_rates_multipleseeds(new_paras_rates, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)

            push!(pq_rates, Paraqualityrates(new_paras_rates, qual_rates_new_paras))
        end

        println("step $i")

    end 

    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution_rates(pq_rates, ther_restriction, fdbck_education, fdbck_income)

    return quality_array

end
function approximation_rr(steps, fdbck_education, fdbck_income, npoints=600)
    pq_rr = Paraqualityrr[]
    quality_array = Float64[]

    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rr_new_paras = eval_rr_multipleseeds(2.5, 3.5, 1.2, 1.2, 1.5, new_paras, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)

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
            new_paras_rr = paraplusnorm(pq_rr[trunc(Int64, rand(truncated(Normal(0,100); lower = 1
            )))].parameters)

            qual_rr_new_paras = eval_rr_multipleseeds(2.5, 3.5, 1.2, 1.2, 1.2, new_paras_rr, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)

            push!(pq_rr, Paraqualityrr(new_paras_rr, qual_rr_new_paras)) 
        end
        println("step $i")

    end 

    sort!(pq_rr, by=p->p.quality)

    present_optimalsolution_rr(pq_rr, ther_restriction, fdbck_education, fdbck_income)

    return quality_array

end

function present_optimalsolution_rates(pq_rates, ther_restriction, fdbck_education, fdbck_income)

    for i=1:3
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

        sim= setup_sim(pq_rates[i].parameters, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, pq_rates[i].parameters, ther_restriction, fdbck_education, fdbck_income)

        println("die Parameter (rates) sind Folgende: ", pq_rates[i].parameters)
        printpara!(sim)
    end
end

function quality_function_para(x, ther_restriction, fdbck_education, fdbck_income)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    parameter_field = collect(0.01:0.01:1)
    quality_array = Float64[]
    lowest =  1.0
    lowest_index = 0
    

    if x == "parent"
        for i in eachindex(parameter_field)
            println(i)
            para = Parameters(rate_parents=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "friends"
        for i in eachindex(parameter_field)
            para = Parameters(rate_friends=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "spouse"
        for i in eachindex(parameter_field)
            para = Parameters(rate_spouse=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "child"
        for i in eachindex(parameter_field)
            para = Parameters(rate_child=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "ac"
        for i in eachindex(parameter_field)
            para = Parameters(rate_ac=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "prev"
        for i in eachindex(parameter_field)
            para = Parameters(prev=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    elseif x == "h"
        for i in eachindex(parameter_field)
            para = Parameters(h=parameter_field[i])
            qual = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income)
            if qual<lowest 
                lowest_index = parameter_field[i]
                lowest = qual
            end
            push!(quality_array, qual)
        end
    end

    return quality_array, parameter_field, lowest_index
end

function present_optimalsolution_rr(pq_rr, ther_restriction, fdbck_education, fdbck_income)

    for i=1:3
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
        sim = setup_sim(pq_rr[i].parameters,d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, pq_rr[i].parameters, ther_restriction, fdbck_education, fdbck_income)

        println("die Parameter (RR) sind Folgende: ", pq_rr[i].parameters)
        printpara!(sim)
    end
end
function params_with_multipleseeds(ther_restriction, fdbck_education, fdbck_income)

    qual_array = Float64[]
    rand_qual_array = Float64[]
    
    for i = 0:20
        para = Parameters(seed = i)

        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
        sim = setup_sim(para,d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, para, ther_restriction, fdbck_education, fdbck_income)

        qual = evaluationrates(sim)
        push!(qual_array, qual)

    end
    for i = 0:20
        rand_para = randpara()
        rand_para.seed = i

        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
        sim = setup_sim(rand_para,d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, rand_para, ther_restriction, fdbck_education, fdbck_income)

        qual = evaluationrates(sim)
        push!(rand_qual_array, qual)
    end
    return qual_array, rand_qual_array
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


