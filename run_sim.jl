include("DepressionModel.jl")
include("setup.jl")

include("analytics.jl")
include("calibration.jl")

function pre_run!(sim, para, years)

    for t in 1:years
        update_agents!(sim, para)
    end

end
function run_sim(sim, para, verbose = false, n_steps = 100)
    #run 100 years first so social network is optimized
    pre_run!(sim, para, 80)

    # random point in time to test increased risks 
    rp = sim.time + rand(1:(n_steps-30))
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

    par_t0 = SimplePerson[]
    fr_t0 = SimplePerson[]
    ac_t0 = SimplePerson[]
    sp_t0 = SimplePerson[]
    ch_t0 = SimplePerson[]

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
            pop_t_0_depressed = copy(sim.pop_currently_depressed)
            par_t0, fr_t0, ac_t0, sp_t0, ch_t0 = contacts_t0(pop_t_0_depressed)

            for p in sim.pop
                if !(p in pop_t_0_depressed)
                    push!(pop_t_0_nondep, p)
                end
            end

            current_risk_results = currentrisks_t0(sim, pop_t_0_depressed)
        end
        if sim.time == (rp + 4) #Zeitabstand im Rosenquist Paper
            fr_t4, ac_t4, sp_t4 = contacts_t4(fr_t0, ac_t0, sp_t0, pop_t_0_depressed)
            increased_risk_results = increasedrisks(current_risk_results..., par_t0, fr_t4, ac_t4, sp_t4, ch_t0, sim)
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
    (; n_depressed, n_healthy , n_depressed_high, n_healthy_high, n_depressed_middle, n_healthy_middle,  n_depressed_low, n_healthy_low, depr_income, health_income, c1, c2, c3, c4, increased_risk_results..., rr_parents_30)
end


function standard!(ther_restriction, fdbck_education, fdbck_income, seed = 0)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

    para = Parameters(ther_restriction = ther_restriction, fdbck_education = fdbck_education, fdbck_income = fdbck_income; seed)

    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

    results = run_sim(sim, para)

    printpara!(sim, results)

    #qualcurrentsolution = eval_params_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

    #println("Qualität der aktuellen Lösung: ", qualcurrentsolution)

    #printgraph!(sim)
    #Plots.plot([c1, c2, c3, c4], labels =["1" "2" "3" "4"])
    #Plots.plot([array_depr, array_health], labels = ["depressed: average income" "healthy: average income"])
    #Plots.plot([heal, depr, healhigh, deprhigh, healmiddle, deprmiddle, heallow, deprlow], labels = ["healthy" "depressed" "healthy high ses" "depressed high ses" "healthy middle ses" "depressed middle ses" "healthy low ses" "depressed low ses"])
    #print_n!(sim)

end

function test!()
    liste = []
    for i = 1:10
        push!(liste, SimplePerson())
    end

    liste[1].state = depressed
    liste[1].n_dep_episode = 1
    liste[5].state = depressed
    liste[5].n_dep_episode = 1
    liste[10].state = depressed
    liste[10].n_dep_episode = 1



    #1&3
    #2&5
    #7&9
    #1&10

    add_eachother!(liste[1], liste[1].friends, liste[3], liste[3].friends)
    add_eachother!(liste[2], liste[2].friends, liste[5], liste[5].friends)
    add_eachother!(liste[7], liste[7].friends, liste[9], liste[9].friends)
    add_eachother!(liste[1], liste[1].friends, liste[10], liste[10].friends)

    kopie = deepcopy(liste) 

    liste[9].state = depressed
    println(kopie[9].state)

    del_unsorted!(liste[5], liste)
    println(length(kopie))

    add_eachother!(liste[4], liste[4].friends, liste[5], liste[5].friends)
    println(length(kopie[4].friends))

    print(everdepressed(liste[5]) == everdepressed(liste[1]))
    print(everdepressed(liste[5]))

    if any(p->everdepressed(p)== everdepressed(liste[5]), liste)
        print("funktioniert")
    end
end

#qual = approximation_rr(50) 
#Plots.plot([qual], labels=["mittlere Abweichung"]) 

#approximation_params_big!(200)

calibration_abcde!()

#hier kann sich ein Graph ausgegeben werden, bei dem geschaut wird, wie sich die Qualität der Simulation über den Bereich des Parameters entwickelt
#mögliche Eingaben= "parent" "friends" "spouse" "child" "ac" "prev" "h"
#quality_plots!()
#qual_h, parameter_field= quality_function_para("h")
#Plots.plot([qual_h], labels = ["mA h"], x = [parameter_field])

#test!()

#standard!(true, false, false)


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