include("DepressionModel.jl")
include("setup.jl")

include("analytics.jl")
include("calibration.jl")

function pre_run!(sim, para, years)

    for t in 1:years
        update_agents!(sim, para)
    end

end
function run_sim(sim, para, verbose = false, n_steps = 200)
    #run 100 years first so social network is optimized
    pre_run!(sim, para, 80)

    # random point in time to test increased risks 
    rp = sim.time + rand(1:(n_steps-30))

    rp1 = sim.time + rand(1:((n_steps-30)/5))
    rp2 = sim.time + (n_steps/5) + rand(1:((n_steps-30)/5))
    rp3 = sim.time + (2*n_steps/5) + rand(1:((n_steps-30)/5))
    rp4 = sim.time + (3*n_steps/5) + rand(1:((n_steps-30)/5))
    rp5 = sim.time + (4*n_steps/5) + rand(1:((n_steps-30)/5))

    # we keep track of the numbers
    n_depressed = Float64[]
    n_healthy = Float64[]

    n_depressed_high = Float64[]
    n_healthy_high = Float64[]

    n_depressed_middle = Float64[]
    n_healthy_middle = Float64[]

    n_depressed_middle_low = Float64[]
    n_healthy_middle_low = Float64[]

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

    par_t0 = SimplePerson[]
    fr_t0 = SimplePerson[]
    ac_t0 = SimplePerson[]
    sp_t0 = SimplePerson[]
    ch_t0 = SimplePerson[]

    current_risk_results = (0.0, 0.0, 0.0, 0.0, 0.0)

    increased_risk_results = (0.0, 0.0, 0.0, 0.0, 0.0)

    rr_parents_30 = 0

    fr_t4_array = Float64[]
    ac_t4_array = Float64[]
    sp_t4_array = Float64[]
    par_t4_array = Float64[]
    ch_t4_array = Float64[]
    
    # simulation steps
    for t in  1:n_steps
        empty!(sim.pop_currently_depressed)
        update_agents!(sim, para)
        push!(n_depressed, count(p -> p.state == depressed, sim.pop)/length(sim.pop))
        push!(n_healthy, count(p -> p.state == healthy, sim.pop)/length(sim.pop))

        push!(n_depressed_high, count(p -> p.state == depressed && p.education == 4, sim.pop)/count(p-> p.education == 4, sim.pop))
        push!(n_healthy_high, count(p -> p.state == healthy && p.education == 4, sim.pop)/count(p->p.education == 4, sim.pop))

        push!(n_depressed_middle, count(p -> p.state == depressed && p.education == 3, sim.pop)/count(p->p.education == 3, sim.pop))
        push!(n_healthy_middle, count(p -> p.state == healthy && p.education == 3, sim.pop)/count(p->p.education == 3, sim.pop))

        push!(n_depressed_middle_low, count(p -> p.state == depressed && p.education == 2, sim.pop)/count(p->p.education == 2, sim.pop))
        push!(n_healthy_middle_low, count(p -> p.state == healthy && p.education == 2, sim.pop)/count(p->p.education == 2, sim.pop))

        push!(n_depressed_low, count(p -> p.state == depressed && p.education == 1, sim.pop)/count(p->p.education == 1, sim.pop))
        push!(n_healthy_low, count(p -> p.state == healthy && p.education == 1, sim.pop)/count(p->p.education == 1, sim.pop))
        # a bit of output
        if verbose
            println(t, ", ", n_depressed[end], ", ", n_healthy[end])
        end

        #calculating increased risks
        if sim.time == rp1 || sim.time == rp2 || sim.time == rp3 || sim.time == rp4 || sim.time == rp5
            pop_t_0_depressed = copy(sim.pop_currently_depressed)
            par_t0, fr_t0, ac_t0, sp_t0, ch_t0 = contacts_t0(pop_t_0_depressed)

            for p in sim.pop
                if !(p in pop_t_0_depressed)
                    push!(pop_t_0_nondep, p)
                end
            end

            current_risk_results = currentrisks_t0(sim, pop_t_0_depressed)
        end
        if sim.time == (rp1 + 4) || sim.time == (rp2 + 4) || sim.time == (rp3 + 4) || sim.time == (rp4 + 4) || sim.time == (rp5 + 4) #Zeitabstand im Rosenquist Paper
            fr_t4, ac_t4, sp_t4 = contacts_t4(fr_t0, ac_t0, sp_t0, pop_t_0_depressed)
            increased_risk_results = increasedrisks(current_risk_results..., par_t0, fr_t4, ac_t4, sp_t4, ch_t0, sim, para)
            push!(fr_t4_array, increased_risk_results.increased_risk_friends_4)
            push!(ac_t4_array, increased_risk_results.increased_risk_ac_4)
            push!(sp_t4_array, increased_risk_results.increased_risk_spouse_4)
            push!(par_t4_array, increased_risk_results.increased_risk_parents_4)
            push!(ch_t4_array, increased_risk_results.increased_risk_children_4)

        end
        if sim.time == (rp + 30) #Zeitabstand bei Rasic et al., 2014 und  RR nicht im zeitlichen Vergleich sondern im Vergleich zu Kinder nichtdepressiver Eltern
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
    incr4_par = mean(par_t4_array)
    incr4_fr = mean(fr_t4_array)
    incr4_ac = mean(ac_t4_array)
    incr4_sp = mean(sp_t4_array)
    incr4_ch = mean(ch_t4_array)
    (; n_depressed, n_healthy , n_depressed_high, n_healthy_high, n_depressed_middle, n_healthy_middle, n_depressed_middle_low, n_healthy_middle_low, n_depressed_low, n_healthy_low, depr_income, health_income, c1, c2, c3, c4, incr4_par, incr4_fr, incr4_ac, incr4_sp, incr4_ch, rr_parents_30)
end


function standard!(ther_restriction, fdbck_education, fdbck_income, seed = 0)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    para = Parameters(ther_restriction = ther_restriction, fdbck_education = fdbck_education, fdbck_income = fdbck_income, job_support_depressed_pop = true ; seed)

    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

    results = run_sim(sim, para)

    printpara!(sim, results)

    #qualcurrentsolution = eval_params_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

    #println("Qualität der aktuellen Lösung: ", qualcurrentsolution)

    #printgraph!(sim)
    #corr_income, corr_education = corr_ses_episodes(sim)

    println(count(p->length(p.children) > 0, sim.pop_dead)/length(sim.pop_dead))  
    #episode_array, percentage_array = depressive_episodes(sim)

    #Plots.plot([results.n_depressed, results.n_healthy])
    #Plots.plot([percentage_array])

    
    #Plots.plot([c1, c2, c3, c4], labels =["1" "2" "3" "4"])
    #Plots.plot([results.depr_income, results.health_income], labels = ["depressed: average income" "healthy: average income"])
    #Plots.plot([results.n_depressed, results.n_depressed_high, results.n_depressed_middle, results.n_depressed_middle_low, results.n_depressed_low], labels = ["depressed" "depressed high ses" "depressed middle ses" "depressed middle low ses" "depressed low ses"])
    #print_n!(sim)

    # println(mean(results.n_depressed_high), " " ,mean(results.n_healthy_high))
    # println(mean(results.n_depressed_middle), " ", mean(results.n_healthy_middle))
    # println(mean(results.n_depressed_middle_low) , " ", mean(results.n_healthy_middle_low))
    # println(mean(results.n_depressed_low), " ", mean(results.n_healthy_low))

end

function test!()
   
    println(collect(15: 5: 80))
end

function distri!()

    x = 0.0
    array = Float64[]

    for i=1:1000
        push!(array, ratetoprob((limit(0, rand(Normal(1,0.2)), 100))))
    end
    sort!(array)
    Plots.histogram(array, bins = 100)

end

#mean_100!()
#sensi_relevant_parameters!()
#ages_prevalences!()
#intervention_analytics!()
#intervention_boxplots!()


#qual = approximation_rr(50) 
#Plots.plot([qual], labels=["mittlere Abweichung"]) 

#approximation_params_big!(60)

#calibration_abcde!()

#hier kann sich ein Graph ausgegeben werden, bei dem geschaut wird, wie sich die Qualität der Simulation über den Bereich des Parameters entwickelt
#mögliche Eingaben= "parent" "friends" "spouse" "child" "ac" "prev" "h"
#quality_plots!()
#qual_h, parameter_field= quality_function_para("h")
#Plots.plot([qual_h], labels = ["mA h"], x = [parameter_field])

#test!()

#standard!(true, true, true)
#distri!()


#histograms_random_effects!(10)

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

#approximation_params!(80)

#hier kann sich ein Graph ausgegeben werden, bei dem geschaut wird, wie sich die Qualität der Simulation über den Bereich des Parameters entwickelt
#mögliche Eingaben= "parent" "friends" "spouse" "child" "ac" "prev" "h"
#quality_plots!()
#qual_h, parameter_field= quality_function_para("h")
#Plots.plot([qual_h], labels = ["mA h"], x = [parameter_field])








#Korrelationsplots
# d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

# para = Parameters()

# sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

# results = run_sim(sim, para)

# printpara!(sim, results)


# ego_f, ego_a, ego_s, ego_p, friendaverage, acaverage, spouse, parentaverage, fr_randomaverage, ac_randomaverage, sp_randomaverage, pa_randomaverage = pl(sim)

# scatter1 = (ego_f, friendaverage, label = cor(ego_f, friendaverage), alpha = 0.15, mc = "red", title = "correlation of depressive episodes of friends")
# scatter2 = (ego_a, acaverage, label = cor(ego_a, acaverage), alpha = 0.15, mc = "red",  title = "correlation of depressive episodes of ac")
# scatter3 = (ego_s, spouse, label = cor(ego_s, spouse), alpha = 0.15, mc = "red",  title = "correlation of depressive episodes of spouses")
# scatter4 = (ego_p, parentaverage, label = cor(ego_p, parentaverage), alpha = 0.15, mc = "red",  title = "correlation of depressive episodes of parents and children")
# Plots.scatter(ego_f, ego_a, ego_s, ego_p, layout = 4)

# bar1 = ([cor(ego_f, friendaverage), cor(ego_f, fr_randomaverage)], label=[round(cor(ego_f, friendaverage), digits = 2), round(cor(ego_f, fr_randomaverage), digits = 2)], color = "red", title = "correlation of depressive episodes of friends compared to random people")
# bar2 = ([cor(ego_a, acaverage), cor(ego_a, ac_randomaverage)], label=[round(cor(ego_a, acaverage), digits = 2), round(cor(ego_a, ac_randomaverage), digits = 2)], color = "red", title = "correlation of depressive episodes of ac compared to random people")
# bar3 = ([cor(ego_s, spouse), cor(ego_s, sp_randomaverage)], label=[round(cor(ego_s, spouse), digits = 2), round(cor(ego_s, sp_randomaverage), digits = 2)], color = "red", title = "correlation of depressive episodes of spouses compared to random people")
# bar4 = ([cor(ego_p, parentaverage), cor(ego_p, pa_randomaverage)], label=[round(cor(ego_p, parentaverage), digits = 2), round(cor(ego_p, pa_randomaverage), digits = 2)], color = "red", title = "correlation of depressive episodes of parents and children compared to random people")
# Plots.bar(bar1, bar2, bar3, bar4, layout = 4)
