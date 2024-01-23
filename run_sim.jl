include("DepressionModel.jl")
include("setup.jl")

include("analytics.jl")
include("calibration.jl")


function run_sim(sim, para, verbose = false, n_steps = 200)
    # random point in time to test increased risks 
    rp = rand(80:(n_steps-30))
    # we keep track of the numbers
    n_depressed = Float64[]
    n_healthy = Float64[]

    n_depressed_high = Float64[]
    n_healthy_high = Float64[]

    n_depressed_middle = Float64[]
    n_healthy_middle = Float64[]

    n_depressed_low = Float64[]
    n_healthy_low = Float64[]

    avg_d = 0.0
    avg_h = 0.0
    depr_income = Float64[]
    health_income = Float64[]

    c1 = Int64[]
    c2 = Int64[]
    c3 = Int64[]
    c4 = Int64[]

    pop_t_0_depressed = []
    pop_t_0_nondep = []

    current_risk_results = (0.0, 0.0, 0.0, 0.0, 0.0)

    increased_risk_results = (0.0, 0.0, 0.0, 0.0, 0.0)

    rr_parents_30 = 0

    # simulation steps
    for t in  1:n_steps
        empty!(sim.pop_currently_depressed)
        update_agents!(sim, para)
        push!(n_depressed, count(p -> p.state == depressed, sim.pop)/length(sim.pop))
        push!(n_healthy, count(p -> p.state == healthy, sim.pop)/length(sim.pop))

        push!(n_depressed_high, count(p -> p.state == depressed && p.income >= 75, sim.pop)/length(sim.pop))
        push!(n_healthy_high, count(p -> p.state == healthy && p.income >= 75, sim.pop)/length(sim.pop))

        push!(n_depressed_middle, count(p -> p.state == depressed && p.income >= 25, sim.pop)/length(sim.pop))
        push!(n_healthy_middle, count(p -> p.state == healthy && p.income >= 25, sim.pop)/length(sim.pop))

        push!(n_depressed_low, count(p -> p.state == depressed && p.income < 25, sim.pop)/length(sim.pop))
        push!(n_healthy_low, count(p -> p.state == healthy && p.income < 25, sim.pop)/length(sim.pop))
        # a bit of output
        if verbose
            println(t, ", ", n_depressed[end], ", ", n_healthy[end])
        end

        #calculating increased risks
        if sim.time == rp
            pop_t_0_depressed = sim.pop_currently_depressed
            for p in sim.pop
                if !(p in pop_t_0_depressed)
                    push!(pop_t_0_nondep, p)
                end
            end
            current_risk_results = currentrisks(sim, pop_t_0_depressed)
        end
        if sim.time == (rp + 4) #Zeitabstand im Rosenquist Paper
            increased_risk_results = increasedrisks(current_risk_results..., pop_t_0_depressed, sim)
        end
        if sim.time == (rp + 30) #Zeitabstand bei Rasic et al., 2014
            rr_parents_30 =  rr_par_30(pop_t_0_depressed, pop_t_0_nondep, sim)
        end
        sim.time += 1

        #Daten für Feedback
        avg_d, avg_h = feedback_analytics(sim)
        push!(depr_income, avg_d)
        push!(health_income, avg_h)

        #Daten für Anzahl an Personen pro Bildungsstand
        cone, ctwo, cthree, cfour = educationlevels(sim)

        push!(c1, cone)
        push!(c2, ctwo)
        push!(c3, cthree)
        push!(c4, cfour)
        #data = observe(Data, sim)
        #log_results(stdout, data)

    end

    #consistencycheck!(sim)

    # return the results (normalized by pop size)
    n = length(sim.pop)
    (; n_depressed, n_healthy , n_depressed_high, n_healthy_high, n_depressed_middle, n_healthy_middle,  n_depressed_low, n_healthy_low, depr_income, health_income, c1, c2, c3, c4, increased_risk_results..., rr_parents_30)
end


function standard!(ther_restriction, fdbck_education, fdbck_income, seed = 0)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    para = Parameters(ther_restriction = ther_restriction, fdbck_education = fdbck_education, fdbck_income = fdbck_income; seed)

    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

    results = run_sim(sim, para)

    printpara!(sim, results)

    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

    println("Qualität der aktuellen Lösung: ", qual_rates_currentsolution)

    #Plots.plot([c1, c2, c3, c4], labels =["1" "2" "3" "4"])
    #Plots.plot([array_depr, array_health], labels = ["depressed: average income" "healthy: average income"])
    #Plots.plot([heal, depr, healhigh, deprhigh, healmiddle, deprmiddle, heallow, deprlow], labels = ["healthy" "depressed" "healthy high ses" "depressed high ses" "healthy middle ses" "depressed middle ses" "healthy low ses" "depressed low ses"])
    #print_n!(sim)

end

#qual = approximation_rr(50) 
#Plots.plot([qual], labels=["mittlere Abweichung"]) 

#qual = approximation_params(50)
#Plots.plot([qual], labels = ["mittlere Abweichung"])

#hier kann sich ein Graph ausgegeben werden, bei dem geschaut wird, wie sich die Qualität der Simulation über den Bereich des Parameters entwickelt
#mögliche Eingaben= "parent" "friends" "spouse" "child" "ac" "prev" "h"
#quality_plots!()
#qual_h, parameter_field= quality_function_para("h")
#Plots.plot([qual_h], labels = ["mA h"], x = [parameter_field])


#histograms_random_effects!(100)




#standard!(true, false, false)

#sensi!()



# df_par_fr, df_par_h, df_h_fr = qual_sensi()


# plt = data(df_par_fr) * mapping(:fr, :qual, color= :par)
# draw(plt)

# plt = data(df_par_h) * mapping(:her, :qual, color= :par)
# draw(plt)

#plt = data(df_h_fr) * mapping(:fr, :qual, color= :her)
#draw(plt)



#comparison_feedback!(true)

#qual, qual_random = params_with_multipleseeds()
#Plots.plot([qual, qual_random], labels=["Qualität bei unterschiedlichem Seed: beste Para" "Zufallspara"])

#qual = approximation_rr(50) 
#Plots.plot([qual], labels=["mittlere Abweichung"]) 

qual = approximation_params(50)
Plots.plot([qual], labels = ["mittlere Abweichung"])

#hier kann sich ein Graph ausgegeben werden, bei dem geschaut wird, wie sich die Qualität der Simulation über den Bereich des Parameters entwickelt
#mögliche Eingaben= "parent" "friends" "spouse" "child" "ac" "prev" "h"
#quality_plots!()
#qual_h, parameter_field= quality_function_para("h")
#Plots.plot([qual_h], labels = ["mA h"], x = [parameter_field])


#histograms_random_effects!(200)




#standard!(true, false, false)

#sensi!()



# df_par_fr, df_par_h, df_h_fr = qual_sensi()


# plt = data(df_par_fr) * mapping(:fr, :qual, color= :par)
# draw(plt)

# plt = data(df_par_h) * mapping(:her, :qual, color= :par)
# draw(plt)

#plt = data(df_h_fr) * mapping(:fr, :qual, color= :her)
#draw(plt)



#comparison_feedback!(true)

#qual, qual_random = params_with_multipleseeds()
#Plots.plot([qual, qual_random], labels=["Qualität bei unterschiedlichem Seed: beste Para" "Zufallspara"])
