using Plots


#Ratenberechnung zur Überprüfung
function ratedep_12month(sim)
    counter = count(p->p.state==depressed, sim.pop)
    count_pop = count(p->p.age>15, sim.pop)
    return counter/count_pop
end

function deprisk_life_15to65(sim)
    
    counter = count(p->p.n_dep_episode_65>0 && p.alive == false, sim.pop_depressed)
    counter_dep = count(p->p.alive == false, sim.pop_non_depressed)
    return counter/(counter_dep + count(p->p.alive == false, sim.pop_depressed))
end

function deprisk_life(sim)
    counter = count(p->p.alive == false, sim.pop_depressed)
    counter_dep = count(p->p.alive == false, sim.pop_non_depressed)
    return counter/(counter + counter_dep)
end

function ratedep_parents_12month(sim)
    popcounter_parents = 0
    deprcounter_parents = 0

    for p in sim.pop 
        counter = count(p->p.state==depressed, p.parents)
        if counter > 0
            popcounter_parents+= 1
            if p.state == depressed 
                deprcounter_parents +=1
            end
        end
    end
    return deprcounter_parents/popcounter_parents
end

function ratedep_parents_life(sim)
    deprcounter_kids = 0
    popcounter_kids = 0
  
    for p in sim.pop_depressed
        if length(p.children) > 0
            counter = count(a->a.n_dep_episode>0, p.children)
            deprcounter_kids += counter
            popcounter_kids += length(p.children)
        end
    end
    return deprcounter_kids/popcounter_kids
end

function ratedep_nondepparents_life(sim)
    deprcounter_kids = 0
    popcounter_kids = 0
  
    for p in sim.pop_non_depressed
        if length(p.children) > 0
            counter = count(a->a.n_dep_episode>0, p.children)
            deprcounter_kids += counter
            popcounter_kids += length(p.children)
        end
    end
    return deprcounter_kids/popcounter_kids
end



function ratedep_friends_12month(sim)
    popcounter_friends = 0
    deprcounter_friends = 0

    for p in sim.pop 
        counter = count(p->p.state==depressed, p.friends)
        if counter > 0
            popcounter_friends+= 1
            if p.state == depressed 
                deprcounter_friends +=1
            end
        end
    end
    return deprcounter_friends/popcounter_friends
end

function ratedep_friends_life(sim)
    deprcounter_friends = 0
    popcounter_friends = 0
  
    for p in sim.pop_depressed
        if length(p.friends) > 0
            counter = count(a->a.n_dep_episode>0, p.friends)
            deprcounter_friends += counter
            popcounter_friends += length(p.friends)
        end
    end
    return deprcounter_friends/popcounter_friends
end

function ratedep_nondepfriends_life(sim)
    deprcounter_friends = 0
    popcounter_friends = 0
  
    for p in sim.pop_non_depressed
        if length(p.friends) > 0
            counter = count(a->a.n_dep_episode>0, p.friends)
            deprcounter_friends += counter
            popcounter_friends += length(p.friends)
        end
    end
    return deprcounter_friends/popcounter_friends
end



function ratedep_ac_12month(sim)
    popcounter_ac = 0
    deprcounter_ac = 0

    for p in sim.pop 
        counter = count(p->p.state==depressed, p.ac)
        if counter > 0
            popcounter_ac+= 1
            if p.state == depressed 
                deprcounter_ac +=1
            end
        end
    end
    return deprcounter_ac/popcounter_ac
end

function ratedep_ac_life(sim)
    deprcounter_ac = 0
    popcounter_ac = 0
  
    for p in sim.pop_depressed
        if length(p.ac) > 0
            counter = count(a->a.n_dep_episode>0, p.ac)
            deprcounter_ac += counter
            popcounter_ac += length(p.ac)
        end
    end
    return deprcounter_ac/popcounter_ac
end
function ratedep_nondepac_life(sim)
    deprcounter_ac = 0
    popcounter_ac = 0
  
    for p in sim.pop_non_depressed
        if length(p.ac) > 0
            counter = count(a->a.n_dep_episode>0, p.ac)
            deprcounter_ac += counter
            popcounter_ac += length(p.ac)
        end
    end
    return deprcounter_ac/popcounter_ac
end



function ratedep_child_12month(sim)
    popcounter_children = 0
    deprcounter_children = 0

    for p in sim.pop 
        counter = count(p->p.state==depressed, p.children)

        if counter > 0
            popcounter_children += 1
            if p.state == depressed 
                deprcounter_children +=1
            end
        end
        
    end
    return deprcounter_children/popcounter_children
end

function ratedep_children_life(sim)
    deprcounter_parents = 0
    popcounter_parents = 0
  
    for p in sim.pop_depressed
        if length(p.parents) > 0
            counter = count(a->a.n_dep_episode>0, p.parents)
            deprcounter_parents += counter
            popcounter_parents += length(p.parents)
        end
    end
    return deprcounter_parents/popcounter_parents
end

function ratedep_nondepchildren_life(sim)
    deprcounter_parents = 0
    popcounter_parents = 0
  
    for p in sim.pop_non_depressed
        if length(p.parents) > 0
            counter = count(a->a.n_dep_episode>0, p.parents)
            deprcounter_parents += counter
            popcounter_parents += length(p.parents)
        end
    end
    return deprcounter_parents/popcounter_parents
end



function ratedep_spouse_12month(sim)
    popcounter_spouse = 0
    deprcounter_spouse = 0

    for p in sim.pop 
        if length(p.spouse) > 0 && p.spouse[1].state == depressed
            popcounter_spouse += 1
            if p.state == depressed 
                deprcounter_spouse +=1
            end
        end 
    end

    return deprcounter_spouse/popcounter_spouse
end

function ratedep_spouse_life(sim)
    deprcounter_spouse = 0
    popcounter_spouse = 0
  
    for p in sim.pop_depressed
        if length(p.spouse) > 0
            counter = count(a->a.n_dep_episode>0, p.spouse)
            deprcounter_spouse += counter
            popcounter_spouse += length(p.spouse)
        end
    end
    return deprcounter_spouse/popcounter_spouse
end

function ratedep_nondepspouse_life(sim)
    deprcounter_spouse = 0
    popcounter_spouse = 0
  
    for p in sim.pop_non_depressed
        if length(p.spouse) > 0
            counter = count(a->a.n_dep_episode>0, p.spouse)
            deprcounter_spouse += counter
            popcounter_spouse += length(p.spouse)
        end
    end
    return deprcounter_spouse/popcounter_spouse
end

function averagerisk(sim)
    avg = 0
    for p in sim.pop
        avg += p.risk
    end

    return avg/length(sim.pop)
end

#Variablen über komplette Population ausgeben
#@observe Data model begin
#    @record "N" Int length(model.pop)
#    @record "prev" ratedep_12month(sim) 
#    @record "prev parents" ratedep_parents_12month(sim)
#    @record "prev friends" ratedep_friends_12month(sim)
#    @record "prev ac" ratedep_ac_12month(sim)
#    @record "prev spouse" ratedep_spouse_12month(sim)
#    @record "prev children" ratedep_child_12month(sim)
#    @record "avg risk" averagerisk(sim)

#end

#data = observe(Data, sim)
#print_header(stdout, Data)
#log_results(stdout, data)


#Berechnung der RR: Wie viel höher ist die Rate depressiver Personen in Abhängigkeit bestimmter depressiver Kontakte?
function rr_parents(sim)
    return ratedep_parents_life(sim)/ratedep_nondepparents_life(sim)
end
function rr_friends(sim)
    return ratedep_friends_life(sim)/ratedep_nondepfriends_life(sim)
end
function rr_spouse(sim)
    return ratedep_spouse_life(sim)/ratedep_nondepspouse_life(sim)
end
function rr_ac(sim)
    return ratedep_ac_life(sim)/ratedep_nondepac_life(sim)
end
function rr_children(sim)
    return ratedep_children_life(sim)/ratedep_nondepchildren_life(sim)
end


mutable struct DeprCounter
    depr :: Int
    pop :: Int
end

DeprCounter() = DeprCounter(0,0)

function count_depr!(ctr, group)
	for person in group
		if ! person.alive
			continue
		end
		ctr.pop += 1
		if person.state == depressed
			ctr.depr += 1
		end
	end
end

function depr_ratio(ctr) 
    if ctr.pop == 0 
        return  0.0001
    elseif ctr.depr == 0 
        return ctr.depr + 1 / (ctr.pop)
    else 
        return ctr.depr/ctr.pop
    end
end

#Berechnung der Erhöhung des Risikos! So wie bei Rosenquist et al. (2011)
#Diese Funktion wird aufgerufen an einem zufälligen Zeitschritt und dann wird vier Jahre später die nächste Funktion aufgerufen, um eine Erhöhung des Risikos zu berechnen
function currentrisks_t0(sim, pop_t_0)
    ctr_children = DeprCounter()
    ctr_friends = DeprCounter()
    ctr_ac = DeprCounter()
    ctr_parents = DeprCounter()
    ctr_spouse = DeprCounter()

    for p in pop_t_0
	    count_depr!(ctr_children, p.parents)
	    count_depr!(ctr_friends, p.friends)
	    count_depr!(ctr_ac, p.ac)
	    count_depr!(ctr_parents, p.children)
	    count_depr!(ctr_spouse, p.spouse)
    end

    return depr_ratio(ctr_children), depr_ratio(ctr_friends), depr_ratio(ctr_ac), depr_ratio(ctr_parents), depr_ratio(ctr_spouse)
end

function contacts_t0(pop_t_0)

    fri = SimplePerson[]
    ac = SimplePerson[]
    sp = SimplePerson[]
    ch = SimplePerson[]
    par = SimplePerson[]

    for p in pop_t_0
        for parent in p.parents
            push!(par, parent)
        end
        for c in p.children
            push!(ch, c)
        end
        for fr in p.friends
            push!(fri, fr)
        end
        for a in p.ac
            push!(ac, a)
        end
        for s in p.spouse
            push!(sp, s)
        end
    end

    return par, fri, ac, sp, ch
end

function contacts_t4(fr, ac, sp, pop_t0)

    fri_t4 = SimplePerson[]
    ac_t4 = SimplePerson[]
    sp_t4 = SimplePerson[]

    for person in pop_t0
        for friend in person.friends
            if friend in fr
                push!(fri_t4, friend)
            end
        end
        for acs in person.ac 
            if acs in ac
                push!(ac_t4, acs)
            end
        end
        for spouse in person.spouse
            if spouse in sp
                push!(sp_t4, spouse)
            end
        end
    end
    return fri_t4, ac_t4, sp_t4
end
#increased risk compared to different point in time
function increasedrisks(former_risk_children, former_risk_friends, former_risk_ac, former_risk_parents, former_risk_spouse, par_t0, fri_t4, ac_t4, sp_t4, ch_t0, sim, para)

    i_ctr_ch = DeprCounter()
    i_ctr_fr = DeprCounter()
    i_ctr_ac = DeprCounter()
    i_ctr_sp = DeprCounter()
    i_ctr_par = DeprCounter()

    count_depr!(i_ctr_ch, par_t0)
    count_depr!(i_ctr_fr, fri_t4)
    count_depr!(i_ctr_ac, ac_t4)
    count_depr!(i_ctr_sp, sp_t4)
    count_depr!(i_ctr_par, ch_t0)

    current_risk_parents = depr_ratio(i_ctr_ch)
    current_risk_friends = depr_ratio(i_ctr_fr)
    current_risk_ac = depr_ratio(i_ctr_ac)
    current_risk_spouse = depr_ratio(i_ctr_sp)
    current_risk_children = depr_ratio(i_ctr_par)


    return (increased_risk_parents_4 = para.scaling * (current_risk_children/(former_risk_children)), 
	    increased_risk_friends_4 = para.scaling * (current_risk_friends/(former_risk_friends)), 
	    increased_risk_ac_4 = para.scaling * (current_risk_ac/(former_risk_ac)), 
	    increased_risk_children_4 = para.scaling * (current_risk_parents/(former_risk_parents)), 
	    increased_risk_spouse_4 = para.scaling* (current_risk_spouse/(former_risk_spouse)))
end


#only for children of parents with depression vs those without depression 30 years later: Rasic et al., 2014
function rr_par_30(pop_t_0_depressed, pop_t_0_nondep, sim)
    ctr_depkids = DeprCounter()

    ctr_nondepkids = DeprCounter()

    for p in pop_t_0_depressed
        count_depr!(ctr_depkids, p.children) 
    end
    for p in pop_t_0_nondep
        count_depr!(ctr_nondepkids, p.children)
    end
    return depr_ratio(ctr_depkids) / (depr_ratio(ctr_nondepkids))
    #(depkids/popkids)/(nondepkids/nondeppopkids)
end


#diverse Funktionen zur Auswertung verschiedenster Aspekte des Modells

function quality_plots!(fdbck_education, fdbck_income)
    qual_parent, parameter_field, lowpar = quality_function_para("parent")
    qual_friends, parameter_field, lowfr= quality_function_para("friends")
    qual_spouse, parameter_field, lowsp = quality_function_para("spouse")
    qual_child, parameter_field, lowch= quality_function_para("child")
    qual_ac, parameter_field, lowac = quality_function_para("ac")
    qual_prev, parameter_field, lowprev = quality_function_para("prev")
    qual_h, parameter_field, lowh = quality_function_para("h")

    Plots.plot([qual_parent, qual_friends, qual_spouse, qual_child, qual_ac, qual_prev, qual_h], labels = ["mA Eltern" "mA Freunde" "mA spouse" "mA Kind" "mA ac" "mA prev" "mA h"], x = [parameter_field])
    
    #println("lowest parent ", lowpar)
    #println("lowest friends ", lowfr)
    #println("lowest spouse ", lowsp)
    #println("lowest child ", lowch)
    #println("lowest ac ", lowac)
    #println("lowest prev ", lowprev)
    #println("lowest h ", lowh)
end

function feedback_analytics(sim)

    avg_d = 0.0
    d_count = 0.0
    avg_h = 0.0
    h_count = 0.0
 
    for person in sim.pop
         if person.state == depressed
             d_count += 1
             avg_d += person.income
         end
    end
    while h_count < d_count
        p = rand(sim.pop)
        if p.state == healthy
            h_count += 1
            avg_h += p.income
        end
    end
 
    return (avg_d/d_count), (avg_h/h_count)
 end

function educationlevels(sim)
    counterone = count(p->p.education==1, sim.pop)
    countertwo = count(p->p.education==2, sim.pop)
    counterthree = count(p->p.education == 3, sim.pop)
    counterfour = count(p->p.education == 4, sim.pop)

    return counterone, countertwo, counterthree, counterfour
end

function comparison_feedback!(ther_restriction)
    #alle Feedbackeffekte aus
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters(ther_restriction = ther_restriction, fdbck_education = false, fdbck_income = false)
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kid)
    results = run_sim(sim, para)
    printpara!(sim, results)
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1*100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2*100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3*100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4*100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    println("Qualität der aktuellen Lösung: keine Feedbackeffekte ", qual_rates_currentsolution)
    

    #Bildungsfeedbackeffekt an
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters(ther_restriction = ther_restriction, fdbck_education = true, fdbck_income = false)
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    results = run_sim(sim, para)
    printpara!(sim, results)  
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1*100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2*100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3*100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4*100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    println("Qualität der aktuellen Lösung: Bildungseffekt an ", qual_rates_currentsolution)
    

    #Einkommen-Depressionsfeedbackeffekt an
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters(ther_restriction = ther_restriction, fdbck_education = false, fdbck_income = true)
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    results = run_sim(sim, para)
    printpara!(sim, results) 
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1*100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2*100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3*100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4*100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    println("Qualität der aktuellen Lösung: Einkommenseffekt an ", qual_rates_currentsolution)
    

    #beide Feedbackeffekte an
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters(ther_restriction = ther_restriction, fdbck_education = true, fdbck_income = true)
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    results = run_sim(sim, para)
    printpara!(sim, results)  
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1 *100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2 *100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3 *100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4 *100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 
    println("Qualität der aktuellen Lösung: beide Feedbackeffekte an ", qual_rates_currentsolution)
    


    Plots.plot([array_depr_none, array_health_none, array_depr_edu, array_health_edu, array_depr_inc, array_health_inc, array_depr_both, array_health_both], labels = ["depressed: none" "healthy: none" "depressed: edu" "healthy: edu" "depressed: inc" "healthy: inc" "depressed: both" "healthy: both"])

    #Plots.plot([array_depr_none, array_health_none], labels = ["depressed: none" "healthy: none"])
    #Plots.plot([array_depr_edu, array_health_edu], labels = ["depressed: edu" "healthy: edu" ])
    #Plots.plot([array_depr_inc, array_health_inc], labels = [ "depressed: inc" "healthy: inc" ])
    #Plots.plot([array_depr_both, array_health_both], labels = [ "depressed: both" "healthy: both"])

end

function print_n!(sim)
    avg_n_friends = 0
    avg_n_ac = 0
    avg_n_parents = 0
    avg_n_children = 0
    c = 0
    avg_n_nokids = 0
    avg_n_nokidsold = 0
    avg_n_spouse = 0
    ages = []

    age_counter = 0
    depepisode_counter = 0

    depepisode_0 = 0
    depepisode_1 = 0
    depepisode_2 = 0
    depepisode_3 = 0
    depepisode_4 = 0
    depepisode_5 = 0
    depepisode_6 = 0
    depepisode_7 = 0
    depepisode_8 = 0
    depepisode_9 = 0
    depepisode_10 = 0
    depepisode_higher = 0



    println("n depressed: ",count(p->p.state==depressed, sim.pop))
    println("n healthy: ",count(p->p.state==healthy, sim.pop))

    for person in sim.pop 
        avg_n_friends += length(person.friends)
        avg_n_ac += length(person.ac)

        if length(person.parents)>0
            avg_n_parents += 1
        end

        if length(person.children) > 0
            avg_n_children += length(person.children)
            c +=1
        elseif person.age >= 50
            avg_n_nokidsold += 1
            avg_n_nokids += 1
        else
            avg_n_nokids += 1
        end

        if length(person.spouse) > 0
            avg_n_spouse += 1
        end

        if person.age > 70
            age_counter += 1
            depepisode_counter += person.n_dep_episode 

            if person.n_dep_episode == 0
                depepisode_0 += 1
            elseif person.n_dep_episode == 1
                depepisode_1 += 1
            elseif person.n_dep_episode == 2
                depepisode_2 += 1
            elseif person.n_dep_episode == 3
                depepisode_3 += 1
            elseif person.n_dep_episode == 4
                depepisode_4 += 1
            elseif person.n_dep_episode == 5
                depepisode_5 += 1
            elseif person.n_dep_episode == 6
                depepisode_6 += 1
            elseif person.n_dep_episode == 7
                depepisode_7 += 1
            elseif person.n_dep_episode == 8
                depepisode_8 += 1
            elseif person.n_dep_episode == 9
                depepisode_9 += 1
            elseif person.n_dep_episode == 10
                depepisode_10 += 1
            else
                depepisode_higher += 1
            end
        end


        push!(ages, person.age)
    end

    println("avg n friends: ", avg_n_friends/length(sim.pop))
    println("avg n ac: ", avg_n_ac/length(sim.pop))
    println("n parents: ", avg_n_parents/length(sim.pop)*100, " %")
    println("avg n children: ", avg_n_children/c)
    println("avg n nokids: ", avg_n_nokids/length(sim.pop)*100, " %")
    println("avg n nokids älter: ", avg_n_nokidsold/count(p->p.age>=50, sim.pop)*100, " %")
    println("avg n spouse: ", avg_n_spouse/length(sim.pop)*100, " %")
    println("avg number of depressive episodes: ", depepisode_counter/age_counter)
    println("number of people with none: ", depepisode_0, " in Prozent: ", depepisode_0/age_counter)
    println("number of people with one: ", depepisode_1, " in Prozent: ", depepisode_1/age_counter)
    println("number of people with two: ", depepisode_2, " in Prozent: ", depepisode_2/age_counter)
    println("number of people with three: ", depepisode_3, " in Prozent: ", depepisode_3/age_counter)
    println("number of people with four: ", depepisode_4, " in Prozent: ", depepisode_4/age_counter)
    println("number of people with five: ", depepisode_5, " in Prozent: ", depepisode_5/age_counter)
    println("number of people with six: ", depepisode_6, " in Prozent: ", depepisode_6/age_counter)
    println("number of people with seven: ", depepisode_7, " in Prozent: ", depepisode_7/age_counter)
    println("number of people with eight: ", depepisode_8, " in Prozent: ", depepisode_8/age_counter)
    println("number of people with nine: ", depepisode_9, " in Prozent: ", depepisode_9/age_counter)
    println("number of people with ten: ", depepisode_10, " in Prozent: ", depepisode_10/age_counter)
    println("number of people with more: ", depepisode_higher, " in Prozent: ", depepisode_higher/age_counter)

    #sort!(ages)
    #hier wäre ein frquency-Plot noch schön für die Altersverteilung
end

function params_with_multipleseeds(ther_restriction, fdbck_education, fdbck_income)

    qual_array = Float64[]
    rand_qual_array = Float64[]
    
    for i = 0:20
        para = Parameters(seed = i)

        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
        sim = setup_sim(para,d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, para)

        qual = evaluationrates(sim)
        push!(qual_array, qual)

    end
    for i = 0:20
        rand_para = randpara()
        rand_para.seed = i

        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
        sim = setup_sim(rand_para,d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        run_sim(sim, rand_para)

        qual = evaluationrates(sim)
        push!(rand_qual_array, qual)
    end
    return qual_array, rand_qual_array
end



function printpara!(sim, results)
   
    println("Zielparameter: ", Optimalparams())

    println( "** prev (12 months): ", ratedep_12month(sim) )
    println( "lifetime risk of depression: ", deprisk_life(sim))
    println( "** risk of depression between 15 and 65: ", deprisk_life_15to65(sim))
    println( " ")
    perc_one, perc_two, perc_three = depressive_episode_analytics(sim)
    println( "** risk for another episode, if person has at least one depressive episode: ", perc_one)
    println( "** risk for another episode, if person has at least two depressive episodes: ", perc_two)
    println( "** risk for another episode, if person has at least three depressive episodes: ", perc_three)
    println(" ")
    println( "prev parents (12 months): ", ratedep_parents_12month(sim) )
    println( "prev parents (life): ", ratedep_parents_life(sim) )
    println(" ")
    println( "prev friends (12 months): ", ratedep_friends_12month(sim) )
    println( "prev friends (life): ", ratedep_friends_life(sim) )
    println(" ")
    println( "prev ac (12 months): ", ratedep_ac_12month(sim) )
    println( "prev ac (life): ", ratedep_ac_life(sim) )
    println(" ")
    println( "prev spouse (12 months): ", ratedep_spouse_12month(sim) )
    println( "prev spouse (life): ", ratedep_spouse_life(sim) )
    println(" ")
    println( "prev children (12 months): ", ratedep_child_12month(sim) )
    println( "prev children (life): ", ratedep_children_life(sim) )
    println(" ")
    println( "avg risk ", averagerisk(sim))
    println(" ")
    println("risk ratio parents: ", rr_parents(sim))
    println("** risk ratio parents 30 years later: ", results.rr_parents_30)
    println("risk ratio friends: ", rr_friends(sim))
    println("risk ratio ac: ", rr_ac(sim))
    println("risk ratio spouse: ", rr_spouse(sim))
    println("risk ratio children: ", rr_children(sim))
    println(" ")
    println("increased risk if parent is depressed 4 years later: ", results.incr4_par - 1)
    println("** increased risk if friend is depressed 4 years later: ", results.incr4_fr - 1)
    println("** increased risk if ac is depressed 4 years later: ", results.incr4_ac - 1)
    println("** increased risk if spouse is depressed 4 years later: ", results.incr4_sp - 1)
    println("increased risk if child is depressed 4 years later: ", results.incr4_ch- 1)
    println(" ")
    h, c, e = heritability_calculations(sim)
    println("Heritabilitätsschätzer: ")
    println("** h: ", h)
    println("** c: ", c)
    println("** e: ", e)
    println(" ")
    println("Korrelation der Eigenvektorzentralität mit der Anzahl depressiver Episoden: ", eigen_centrality(sim))
    println("_______________________________________________________________________________")
end

function standard_statistics(steps)
    # prev = Float64[]
    # prev_parents = Float64[]
    # prev_friends = Float64[]
    # prev_ac = Float64[]
    # prev_kids = Float64[]
    # prev_spouse = Float64[]
    # avg_risk = Float64[]
    # qual = Float64[]
    q = 0

    df_all_params = DataFrame(prev = [], prev_parents = [], prev_friends = [], prev_ac = [], prev_kids = [], prev_spouse = [], avg_risk = [], qual = [])


    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    results = run_sim(sim, para)


    for i=1:steps

        results = run_sim(sim, para)

        # push!(prev, ratedep_12month(sim))
        # push!(prev_parents, ratedep_parents_12month(sim))
        # push!(prev_friends, ratedep_friends_12month(sim))
        # push!(prev_ac, ratedep_ac_12month(sim))
        # push!(prev_kids, ratedep_child_12month(sim))
        # push!(prev_spouse, ratedep_spouse_12month(sim))
        # push!(avg_risk, averagerisk(sim))
        q =  eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
        # push!(qual, q)

        push!(df_all_params, [round(ratedep_12month(sim), digits = 2) round(ratedep_parents_12month(sim), digits = 2) round(ratedep_friends_12month(sim), digits = 2) round(ratedep_ac_12month(sim), digits = 2) round(ratedep_child_12month(sim), digits = 2) round(ratedep_spouse_12month(sim), digits = 2) round(averagerisk(sim), digits = 2) round(q, digits = 5)])        

        print("+")
    end

    # println("Das Minimum der Prävalenz ist: ", minimum(prev))
    # println("Das Maximum der Prävalenz ist: ", maximum(prev))
    # println("Der Durchschnitt der Prävalenz ist: ", mean(prev))
    # println("Die Varianz der Prävalenz ist: ", var(prev))

    # println("Das Minimum der Prävalenz (Eltern) ist: ", minimum(prev_parents))
    # println("Das Maximum der Prävalenz (Eltern) ist: ", maximum(prev_parents))
    # println("Der Durchschnitt der Prävalenz (Eltern) ist: ", mean(prev_parents))
    # println("Die Varianz der Prävalenz (Eltern) ist: ", var(prev_parents))

    # println("Das Minimum der Prävalenz (Freunde) ist: ", minimum(prev_friends))
    # println("Das Maximum der Prävalenz (Freunde) ist: ", maximum(prev_friends))
    # println("Der Durchschnitt der Prävalenz (Freunde) ist: ", mean(prev_friends))
    # println("Die Varianz der Prävalenz (Freunde) ist: ", var(prev_friends))

    # println("Das Minimum der Prävalenz (ac) ist: ", minimum(prev_ac))
    # println("Das Maximum der Prävalenz (ac) ist: ", maximum(prev_ac))
    # println("Der Durchschnitt der Prävalenz (ac) ist: ", mean(prev_ac))
    # println("Die Varianz der Prävalenz (ac) ist: ", var(prev_ac))

    # println("Das Minimum der Prävalenz (Partner) ist: ", minimum(prev_spouse))
    # println("Das Maximum der Prävalenz (Partner) ist: ", maximum(prev_spouse))
    # println("Der Durchschnitt der Prävalenz (Partner) ist: ", mean(prev_spouse))
    # println("Die Varianz der Prävalenz (Partner) ist: ", var(prev_spouse))

    # println("Das Minimum der Prävalenz (Kinder) ist: ", minimum(prev_kids))
    # println("Das Maximum der Prävalenz (Kinder) ist: ", maximum(prev_kids))
    # println("Der Durchschnitt der Prävalenz (Kinder) ist: ", mean(prev_kids))
    # println("Die Varianz der Prävalenz (Kinder) ist: ", var(prev_kids))

    # println("Das Minimum des durchschnittlichen Risikos ist: ", minimum(avg_risk))
    # println("Das Maximum des durchschnittlichen Risikos ist: ", maximum(avg_risk))
    # println("Der Durchschnitt des durchschnittlichen Risikos ist: ", mean(avg_risk))
    # println("Die Varianz des durchschnittlichen Risikos ist: ", var(avg_risk))

    # println("Das Minimum der Abweichung ist: ", minimum(qual))
    # println("Das Maximum der Abweichung ist: ", maximum(qual))
    # println("Der Durchschnitt der Abweichung ist: ", mean(qual))
    # println("Die Varianz der Abweichung ist: ", var(qual))

    return df_all_params
end

function rand_statistics(steps)
    prev = Float64[]
    prev15_65 = Float64[]
    rr_30_par = Float64[]
    rr_4_fr = Float64[]
    rr_4_ac = Float64[]
    rr_4_sp = Float64[]
    h = Float64[]

    qual = Float64[]
    q = 0

    rr_parents_30 = 0
    increased_risk_friends_4 = 0 
    increased_risk_spouse_4 = 0 
    increased_risk_ac_4= 0

    df_all_params = DataFrame(prev = [], prev15_65 = [], prev_life = [], rr_30_par = [], rr_4_fr = [], rr_4_ac = [], rr_4_sp = [], h = [], qual = [])
  
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)


    for i=1:steps

        results=run_sim(sim, para)
        
        q =  eval_params_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, 5)
        h,c,e = heritability_calculations(sim)
        push!(df_all_params, [round(ratedep_12month(sim), digits = 2) round(deprisk_life_15to65(sim), digits = 2) round(deprisk_life(sim), digits = 2) round(results.rr_parents_30, digits = 2) round(results.incr4_fr, digits = 2) round(results.incr4_ac, digits = 2) round(results.incr4_sp, digits = 2) round(h, digits = 2) round(q, digits = 5)])        

        print("+")
    end

    return df_all_params
end

function histograms_random_effects!(steps)
    df_all_params = rand_statistics(steps)

    print(df_all_params)

    prev_frequency = data(df_all_params) * mapping(:prev) * AlgebraOfGraphics.histogram(bins=10)
    draw(prev_frequency)

    # prev_15_65_frequency = data(df_all_params) * mapping(:prev_15_65) * AlgebraOfGraphics.histogram(bins=10)
    # draw(prev_15_65_frequency)

    # prev_rr_4_friends_frequency = data(df_all_params) * mapping(:rr_4_fr) * AlgebraOfGraphics.histogram(bins=10)
    # draw(prev_rr_4_friends_frequency)

    # prev_rr_4_ac_frequency = data(df_all_params) * mapping(:rr_4_ac) * AlgebraOfGraphics.histogram(bins=10)
    # draw(prev_rr_4_ac_frequency)

    # prev_rr_4_spouse_frequency = data(df_all_params) * mapping(:rr_4_sp) * AlgebraOfGraphics.histogram(bins=10)
    # draw(prev_rr_4_spouse_frequency)

    # prev_h_frequency = data(df_all_params) * mapping(:h) * AlgebraOfGraphics.histogram(bins=10)
    # draw(prev_h_frequency)

    # prev_rr_par_30 = data(df_all_params) * mapping(:rr_30_par) * AlgebraOfGraphics.histogram(bins=10)
    # draw(prev_rr_par_30)

    # qual_frequency = data(df_all_params) * mapping(:qual) * AlgebraOfGraphics.histogram(bins=10)
    # draw(qual_frequency)

end
function heritability_calculations(sim)
    #Die phänotypische Korrelation zwischen Verwandten muss durch gemeinsame (additive) genetische Varianz (h2) und geteilte Umwelteinflüsse (c2) ausdrückbar sein:
    # rMZ = h^2 + c^2
    #Da dizygote Zwillinge nur 50% der genetischen Varianz teilen, ergibt sich in ihrem Fall:
    # rMZ = h^2/2 + c^2

    #Setzen wir beide Formeln miteinander in Verhältnis, können wir nach h2 auflösen, also den Anteil geteilter genetischer Varianz an der geteilten Varianz im betrachteten Phänotyp insgesamt bestimmen:
    # 2(rMZ - rDZ) = h^2 --> Falconer Formel 

    #Schlussfolgerung: Aus 1 – rMZ bzw. 1 – (h^2 + c^2) ergibt sich der Einfluss der ungeteilten Umwelt e^2


    #Zunächst die relevanten Arrays erzeugen: die Anzahl depressiver Episoden der jeweiligen Geschwister
    episodes_identtwin_a = Int64[]
    episodes_identtwin_b = Int64[]

    episodes_frattwin_a = Int64[]
    episodes_frattwin_b = Int64[]

    #die relevanten Korrelationen
    cor_ident = 0
    cor_frat = 0
    h_falc = 0 
    c_falc = 0
    e_falc = 0

    for person in sim.pop_identical_twins
        if person.age > 15
            push!(episodes_identtwin_a, person.n_dep_episode)
            push!(episodes_identtwin_b, person.twin[1].n_dep_episode)
        end
    end
    for person in sim.pop_fraternal_twins
        if person.age > 15
            push!(episodes_frattwin_a, person.n_dep_episode)
            push!(episodes_frattwin_b, person.twin[1].n_dep_episode)
        end
    end

    if length(episodes_identtwin_a) > 0 && length(episodes_identtwin_b) > 0 && length(episodes_frattwin_a) > 0 && length(episodes_frattwin_b) > 0
        cor_ident = cor(episodes_identtwin_a, episodes_identtwin_b)
        cor_frat = cor(episodes_frattwin_a, episodes_frattwin_b)

        h_falc = 2(cor_ident - cor_frat)
        c_falc = cor_ident - h_falc
        e_falc = 1 - cor_ident
    end

    if  isnan(h_falc)|| isnan(c_falc)|| isnan(e_falc)
        h_falc = 0
        c_falc = 0
        e_falc = 0
    end
    return h_falc, c_falc, e_falc
end

# Berechnung der Risk Ratios
function toriskratio(sim)
    risk_parents = 0
    pop_parents = 0

    risk_non_par = 0
    pop_non_par= 0

    risk_friends = 0
    risk_non_friends = 0

    pop_friends = 0
    pop_non_friends=0

    risk_ac = 0
    risk_non_ac = 0

    pop_ac = 0
    pop_non_ac = 0

    risk_spouse = 0
    risk_non_spouse = 0

    pop_spouse = 0
    pop_non_spouse = 0

    risk_children = 0
    risk_non_children = 0
    pop_children = 0
    pop_non_children = 0

    avg_parents = 0
    avg_non_parents = 0
    avg_friends = 0
    avg_non_friends = 0
    avg_ac = 0
    avg_non_ac = 0
    avg_spouse = 0
    avg_non_spouse = 0
    avg_children = 0
    avg_non_children = 0

    rr_par = 0
    rr_fr = 0
    rr_ac = 0
    rr_sp = 0
    rr_ch = 0

    #risk ration for people with depressed parents
    for person in sim.pop
        f = false
        for parent in person.parents
            if parent.state == depressed
                f = true
            end
        end
        if f
            risk_parents += person.risk
            pop_parents += 1
        else
            risk_non_par += person.risk 
            pop_non_par += 1
        end
    end
    avg_parents = risk_parents/pop_parents
    avg_non_parents = risk_non_par/pop_non_par
    rr_par = avg_parents/avg_non_parents

    #risk ration for people with depressed friends
    for person in sim.pop
        f = false
        for friend in person.friends
            if friend.state == depressed
                f = true
            end
        end
        if f
            risk_friends += person.risk
            pop_friends += 1
        else
            risk_non_friends += person.risk 
            pop_non_friends += 1
        end
    end
    avg_friends = risk_friends/pop_friends
    avg_non_friends = risk_non_friends/pop_non_friends
    rr_fr = avg_friends/avg_non_friends

    #risk ration for people with depressed acs
    for person in sim.pop
        f = false
        for ac in person.ac
            if ac.state == depressed
                f = true
            end
        end
        if f
            risk_ac += person.risk
            pop_ac += 1
        else
            risk_non_ac += person.risk 
            pop_non_ac += 1
        end
    end
    avg_ac = risk_ac/pop_ac
    avg_non_ac = risk_non_ac/pop_non_ac
    rr_ac = avg_ac/avg_non_ac

    #risk ration for people with depressed spouse
    for person in sim.pop
        f = false
        if length(person.spouse) > 0 && person.spouse[1].state == depressed
            f = true
        end
        if f
            risk_spouse += person.risk
            pop_spouse += 1
        else
            risk_non_spouse += person.risk 
            pop_non_spouse += 1
        end
    end
    avg_spouse = risk_spouse/pop_spouse
    avg_non_spouse = risk_non_spouse/pop_non_spouse
    rr_sp = avg_spouse/avg_non_spouse

    #risk ration for people with depressed children
    for person in sim.pop
        f = false
        for child in person.children
            if child.state == depressed
                f = true
            end
        end
        if f
            risk_children += person.risk
            pop_children += 1
        else
            risk_non_children += person.risk 
            pop_non_children += 1
        end
    end
    avg_children = risk_children/pop_children
    avg_non_children = risk_non_children/pop_non_children
    rr_ch = avg_children/avg_non_children

    return rr_par, rr_fr, rr_ac, rr_sp, rr_ch
end


function printgraph!(sim)

    #every person is counted
    D = Dict{SimplePerson, Int64}()
    membership = Int64[]

    for i in eachindex(sim.pop)
        D[sim.pop[i]] = i 

        if sim.pop[i].state == depressed
            push!(membership, 1)
        elseif everdepressed(sim.pop[i])
            push!(membership, 2)
        else
            push!(membership, 3)
        end
    end

    G = Graph(length(sim.pop))

    for person in sim.pop
        for parent in person.parents
            if parent.alive
                add_edge!(G, D[person], D[parent])
            end
        end
        for friend in person.friends
            add_edge!(G, D[person], D[friend])
        end
        for ac in person.ac
            add_edge!(G, D[person], D[ac])
        end
        for children in person.children
            add_edge!(G, D[person], D[children])
        end
        for spouse in person.spouse
            add_edge!(G, D[person], D[spouse])
        end
        for twin in person.twin
            add_edge!(G, D[person], D[twin])
        end
    end
    nodecolor = [colorant"red", colorant"orange", colorant"blue"] 
    nodefillc = nodecolor[membership]


    adj = adjacency_matrix(G)
    gplot(G, nodefillc=nodefillc)
end

function pl(sim)
    
    ego_f = Int64[]
    ego_a = Int64[]
    ego_s = Int64[]
    ego_p = Int64[]

    friendaverage = Float64[]
    spouse = Int64[]
    acaverage = Float64[]
    parentaverage = Float64[]

    fr_randomaverage = Float64[]
    sp_randomaverage = Float64[]
    ac_randomaverage = Float64[]
    pa_randomaverage = Float64[]

    for p in sim.pop
        if p.age > 18
            f = 0
            a = 0
            s = 0
            pa = 0

            f_r = 0
            a_r = 0
            s_r = 0
            pa_r = 0

            for friend in p.friends
                f += friend.n_dep_episode
            end
            for i=1:length(p.friends)
                f_r += rand(sim.pop).n_dep_episode
            end

            for ac in p.ac
                a += ac.n_dep_episode
            end
            for i=1:length(p.ac)
                a_r += rand(sim.pop).n_dep_episode
            end

            for parent in p.parents
                pa += parent.n_dep_episode
            end
            for i=1:length(p.parents)
                pa_r += rand(sim.pop).n_dep_episode
            end


            if length(p.spouse) > 0
                s = p.spouse[1].n_dep_episode
                s_r = rand(sim.pop).n_dep_episode
                push!(spouse, s)
                push!(ego_s, p.n_dep_episode)

                push!(sp_randomaverage, s_r)
            end

            if length(p.friends)>0
                push!(friendaverage, f/length(p.friends))
                push!(ego_f, p.n_dep_episode)

                push!(fr_randomaverage, f_r/length(p.friends))

            end
            if length(p.ac)>0
                push!(acaverage, a/length(p.ac))
                push!(ego_a, p.n_dep_episode)

                push!(ac_randomaverage, a_r/length(p.ac))
            end
            if length(p.parents)>0
                push!(parentaverage, pa/length(p.parents))
                push!(ego_p, p.n_dep_episode)

                push!(pa_randomaverage, pa_r/length(p.parents))
            end
        end
        
    end

    return ego_f, ego_a, ego_s, ego_p, friendaverage, acaverage, spouse, parentaverage, fr_randomaverage, ac_randomaverage, sp_randomaverage, pa_randomaverage
end

function depressive_episodes(sim)
    episode_array = Int64[]
    percentage_array = Float64[]

    sort!(sim.pop_dead, by=p->p.n_dep_episode)
    dep = count(p->p.n_dep_episode == 0, sim.pop_dead)/length(sim.pop_dead)
    push!(episode_array, 0)
    push!(percentage_array, dep)

    for i=1:last(sim.pop_dead).n_dep_episode
        push!(episode_array, i)
        push!(percentage_array, count(p->p.n_dep_episode >= i, sim.pop_dead)/length(sim.pop_dead))
    end

    return episode_array, percentage_array
end

function depressive_episode_analytics(sim)
    episode_array, percentage_array = depressive_episodes(sim)

    if length(episode_array)>4
        perc_one = percentage_array[3]/percentage_array[2]
        perc_two = percentage_array[4]/percentage_array[3]
        perc_three = percentage_array[5]/percentage_array[4]

        return perc_one, perc_two, perc_three
    else
        return 1.0, 1.0, 1.0
    end
end

function eigen_centrality(sim)
    #every person is counted
    D = Dict{SimplePerson, Int64}()
    centralities = []
    dep_episodes = Int64[]

    for i in eachindex(sim.pop)
        D[sim.pop[i]] = i 
    end

    G = Graph(length(sim.pop))

    for person in sim.pop
        for parent in person.parents
            if parent.alive
                add_edge!(G, D[person], D[parent])
            end
        end
        for friend in person.friends
            add_edge!(G, D[person], D[friend])
        end
        for ac in person.ac
            add_edge!(G, D[person], D[ac])
        end
        for children in person.children
            add_edge!(G, D[person], D[children])
        end
        for spouse in person.spouse
            add_edge!(G, D[person], D[spouse])
        end
        for twin in person.twin
            add_edge!(G, D[person], D[twin])
        end
    end

    centralities = eigenvector_centrality(G)

    for i in eachindex(sim.pop)
        push!(dep_episodes, sim.pop[i].n_dep_episode)
    end

    return  cor(dep_episodes, centralities)
end


#Ergebnisfunktionen Paper
function therapy_recurrence(sim)

    rem = 0

    if length(sim.pop_therapy_all) > 0
        rem =  1-(length(sim.pop_therapy_recurrent)/length(sim.pop_therapy_all))
    end

    return rem 

end


function mean_100!()

    prev_year = Float64[]
    lifetime = Float64[]
    life_1565 = Float64[]
    one_more = Float64[]
    two_more = Float64[]
    three_more = Float64[]
    rr_par_30 = Float64[]
    inc_fr = Float64[]
    inc_ac = Float64[]
    inc_sp = Float64[]
    h_array = Float64[]
    c_array = Float64[]
    e_array = Float64[]
    corr_array = Float64[]

    ages_prev = []
    ages_prev_mean = Float64[]

    corr_age_nepisodes = Float64[]

    fr_depressed = Float64[]
    fr_non_depressed = Float64[]

    corr_income_episodes = Float64[]
    corr_education_episodes = Float64[]

    therapy_remission_prob = Float64[]

    m_e = 0
    m_r = 0

    m_e_nd = 0
    m_r_nd = 0


    for i=1:100
        friends_depressed = 0
        friends_non_depressed = 0
    
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

        para = Parameters()

        sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

        results = run_sim(sim, para)



        push!(prev_year, ratedep_12month(sim))
        push!(lifetime, deprisk_life(sim))
        push!(life_1565, deprisk_life_15to65(sim))
        perc_one, perc_two, perc_three = depressive_episode_analytics(sim)
        push!(one_more, perc_one)
        push!(two_more, perc_two)
        push!(three_more, perc_three)
        push!(rr_par_30, results.rr_parents_30)
        push!(inc_fr, results.incr4_fr)
        push!(inc_ac, results.incr4_ac)
        push!(inc_sp, results.incr4_sp)

        h, c, e = heritability_calculations(sim)
        push!(h_array, h)
        push!(c_array, c)
        push!(e_array, e)

        corr = eigen_centrality(sim)
        push!(corr_array, corr)

        push!(ages_prev, ages_prevalences(sim))

        push!(corr_age_nepisodes, corr_age_episodes(sim))

        corr_income, corr_education = corr_ses_episodes(sim)
        push!(corr_income_episodes, corr_income)
        push!(corr_education_episodes, corr_education)
    
        for person in sim.pop_depressed
            friends_depressed += length(person.friends) 
        end
        for person in sim.pop_non_depressed
            friends_non_depressed += length(person.friends)
        end
        push!(fr_depressed, friends_depressed/length(sim.pop_depressed))
        push!(fr_non_depressed, friends_non_depressed/length(sim.pop_non_depressed))

        push!(therapy_remission_prob, 1-length(sim.pop_therapy_recurrent)/length(sim.pop_therapy_all))
    end


    println("Zielparameter: ", Optimalparams())

    println( "** prev (12 months): ", mean(prev_year), " sd: ", std(prev_year))
    println( " lifetime risk of depression: ", mean(lifetime), " sd: ", std(lifetime))
    println( "** risk of depression between 15 and 65: ", mean(life_1565), " sd: ", std(life_1565))
    println( " ")
    println( "** risk for another episode, if person has at least one depressive episode: ", mean(one_more), " sd: ", std(one_more))
    println( "** risk for another episode, if person has at least two depressive episodes: ", mean(two_more), " sd: ", std(two_more))
    println( "** risk for another episode, if person has at least three depressive episodes: ", mean(three_more), " sd: ", std(three_more))
    println(" ")
    println("** risk ratio parents 30 years later: ", mean(rr_par_30), " sd: ", std(rr_par_30))
    println(" ")
    println("** increased risk if friend is depressed 4 years later: ", mean(inc_fr) - 1, " sd: ", std(inc_fr))
    println("** increased risk if ac is depressed 4 years later: ", mean(inc_ac) - 1, " sd: ", std(inc_ac))
    println("** increased risk if spouse is depressed 4 years later: ", mean(inc_sp) - 1, " sd: ", std(inc_sp))
    println(" ")
    println("Heritabilitätsschätzer: ")
    println("** h: ", mean(h_array), " sd: ", std(h_array))
    println("** c: ", mean(c_array), " sd: ", std(c_array))
    println("** e: ", mean(e_array), " sd: ", std(e_array))
    println(" ")
    println("Korrelation der Eigenvektorzentralität mit der Anzahl depressiver Episoden: ", mean(corr_array), " sd: ", std(corr_array))
    println(" ")
    println("Korrelation der depressiven Episoden mit Einkommen: ", )
    println("Korrelation der depressiven Episoden mit Bildung: ", )
    println("average number of friends: depressed people: ", mean(fr_depressed), " sd: ", std(fr_depressed))
    println("average number of friends: nondepressed people: ", mean(fr_non_depressed), " sd: ", std(fr_non_depressed))
    println("average remission prob after therapy: ", mean(therapy_remission_prob))
    println("_______________________________________________________________________________")


  
    #das noch mitteln
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 
    results = run_sim(sim, para)

  
    for person in sim.pop_depressed
        m_e += mean(person.environmental_risk)
        m_r += (person.pheno_susceptibility/person.pheno_resilience)
    end
    for person in sim.pop_non_depressed
        m_e_nd += mean(person.environmental_risk)
        m_r_nd += (person.pheno_susceptibility/person.pheno_resilience)
    end

    println(m_e/length(sim.pop_depressed), " ", m_r/length(sim.pop_depressed))
    println(m_e_nd/length(sim.pop_non_depressed), " ", m_r_nd/length(sim.pop_non_depressed))

    #Alter und Prävalenz 
    ages_prev_mean = mean(ages_prev, dims= 1)
    xticks=collect(15:80)
    Plots.plot([ages_prev_mean], xlabel="age", ylabel="prevalence", legend = false)


end

function corr_ses_episodes(sim)


    income_array = Float64[]
    education_array = Int64[]
    n_episodes_array = Float64[]

    for person in sim.pop
        push!(income_array, person.income)
        push!(education_array, person.education)
        push!(n_episodes_array, person.n_dep_episode)
    end

    return cor(income_array, n_episodes_array), cor(education_array, n_episodes_array)

end
function ages_prevalences(sim)

    counter_people = 0
    counter_depressed_people = 0
    ages_prev = Float64[]

    for i=0:80
        counter_people = count(p->p.age == i , sim.pop)
        counter_depressed_people = count(p->p.age == i && p.state == depressed, sim.pop)
        push!(ages_prev, counter_depressed_people/counter_people)
    end

    return ages_prev
end

function corr_age_episodes(sim)

    c_episodes = Float64[]
    ages = Int64[]

    for i=15:80
        n_ep = 0
        person_counter = 0
        push!(ages, i)

        for person in sim.pop
            if person.age == i
                n_ep += person.n_dep_episode
                person_counter +=1
            end
        end

        push!(c_episodes, n_ep/person_counter)
    end
    return cor(ages, c_episodes)
end




function sensi_relevant_parameters!()

    prev_year = Float64[]
    lifetime = Float64[]
    life_1565 = Float64[]
    one_more = Float64[]
    two_more = Float64[]
    three_more = Float64[]
    rr_par_30 = Float64[]
    inc_fr = Float64[]
    inc_ac = Float64[]
    inc_sp = Float64[]
    h_array = Float64[]
    c_array = Float64[]
    e_array = Float64[]
    corr_array = Float64[]


    para = Parameters()
    para_plus_half = Parameters(homophily_friends = para.homophily_friends+ (0.5* para.homophily_friends))
    para_minus_half = Parameters(homophily_friends = para.homophily_friends - (0.5* para.homophily_friends))
    para_plus = Parameters(homophily_friends = para.homophily_friends + (para.homophily_friends))
    para_minus = Parameters(homophily_friends = para.homophily_friends - (para.homophily_friends))



    mean_normal, sd_normal = return_mean_100(para)
    mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    mean_plus, sd_plus = return_mean_100(para_plus)
    mean_minus, sd_minus = return_mean_100(para_minus)
   
    label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    #push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    #push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    #push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    #push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    #push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    #push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    #push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    #push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    #push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["12 month prevalence" "lifetime prevalence" "recurrence 1" "recurrence 2" "recurrence 3"], lw=2, size=(400,300), legend =:outerbottom, xlabel = "parameter change", ylabel="outcome")

    #rate parents
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(rate_parents = para.rate_parents+ (0.5* para.rate_parents))
    # para_minus_half = Parameters(rate_parents = para.rate_parents - (0.5* para.rate_parents))
    # para_plus = Parameters(rate_parents = para.rate_parents + (para.rate_parents))
    # para_minus = Parameters(rate_parents = para.rate_parents - (para.rate_parents))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p2 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="rate parents", legend =:outertopright)

    # #rate friends
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(rate_friends = para.rate_friends+ (0.5* para.rate_friends))
    # para_minus_half = Parameters(rate_friends = para.rate_friends - (0.5* para.rate_friends))
    # para_plus = Parameters(rate_friends = para.rate_friends + (para.rate_friends))
    # para_minus = Parameters(rate_friends = para.rate_friends - (para.rate_friends))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p3 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="rate friends", legend = false)

    # #rate spouse
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(rate_spouse = para.rate_spouse+ (0.5* para.rate_spouse))
    # para_minus_half = Parameters(rate_spouse = para.rate_spouse - (0.5* para.rate_spouse))
    # para_plus = Parameters(rate_spouse = para.rate_spouse + (para.rate_spouse))
    # para_minus = Parameters(rate_spouse = para.rate_spouse - (para.rate_spouse))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p4 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="rate spouse", legend = false)

    # #rate ac
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(rate_ac = para.rate_ac+ (0.5* para.rate_ac))
    # para_minus_half = Parameters(rate_ac = para.rate_ac - (0.5* para.rate_ac))
    # para_plus = Parameters(rate_ac = para.rate_ac + (para.rate_ac))
    # para_minus = Parameters(rate_ac = para.rate_ac - (para.rate_ac))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p5 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="rate ac", legend = false)

    # #rate spouse healthy
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(rate_spouse_healthy = para.rate_spouse_healthy+ (0.5* para.rate_spouse_healthy))
    # para_minus_half = Parameters(rate_spouse_healthy = para.rate_spouse_healthy - (0.5* para.rate_spouse_healthy))
    # para_plus = Parameters(rate_spouse_healthy = para.rate_spouse_healthy + (para.rate_spouse_healthy))
    # para_minus = Parameters(rate_spouse_healthy = para.rate_spouse_healthy - (para.rate_spouse_healthy))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p6 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="rate spouse healthy", legend = false)

    # #rate friends healthy
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(rate_friends_healthy = para.rate_friends_healthy+ (0.5* para.rate_friends_healthy))
    # para_minus_half = Parameters(rate_friends_healthy = para.rate_friends_healthy - (0.5* para.rate_friends_healthy))
    # para_plus = Parameters(rate_friends_healthy = para.rate_friends_healthy + (para.rate_friends_healthy))
    # para_minus = Parameters(rate_friends_healthy = para.rate_friends_healthy - (para.rate_friends_healthy))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p7 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="rate friends healthy", legend = false)

    # #h 
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(h = para.h+ (0.5* para.h))
    # para_minus_half = Parameters(h = para.h - (0.5* para.h))
    # para_plus = Parameters(h = para.h + (para.h))
    # para_minus = Parameters(h = para.h - (para.h))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p8 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="heritability", legend = false)

    # #h resilience
    # prev_year = Float64[]
    # lifetime = Float64[]
    # life_1565 = Float64[]
    # one_more = Float64[]
    # two_more = Float64[]
    # three_more = Float64[]
    # rr_par_30 = Float64[]
    # inc_fr = Float64[]
    # inc_ac = Float64[]
    # inc_sp = Float64[]
    # h_array = Float64[]
    # c_array = Float64[]
    # e_array = Float64[]
    # corr_array = Float64[]


    # para = Parameters()
    # para_plus_half = Parameters(h_resilience = para.h_resilience+ (0.5* para.h_resilience))
    # para_minus_half = Parameters(h_resilience = para.h_resilience - (0.5* para.h_resilience))
    # para_plus = Parameters(h_resilience = para.h_resilience + (para.h_resilience))
    # para_minus = Parameters(h_resilience = para.h_resilience - (para.h_resilience))



    # mean_normal, sd_normal = return_mean_100(para)
    # mean_plus_half, sd_plus_half = return_mean_100(para_plus_half)
    # mean_minus_half, sd_minus_half = return_mean_100(para_minus_half)
    # mean_plus, sd_plus = return_mean_100(para_plus)
    # mean_minus, sd_minus = return_mean_100(para_minus)
   
    # label_ticks = ["x0", "x0.5", "x1", "x1.5", "x2"]

    # push!(prev_year, mean_minus[1], mean_minus_half[1], mean_normal[1], mean_plus_half[1], mean_plus[1])
    # push!(lifetime, mean_minus[2], mean_minus_half[2], mean_normal[2], mean_plus_half[2], mean_plus[2])
    # push!(life_1565, mean_minus[3], mean_minus_half[3], mean_normal[3], mean_plus_half[3], mean_plus[3])
    # push!(one_more, mean_minus[4], mean_minus_half[4], mean_normal[4], mean_plus_half[4], mean_plus[4])
    # push!(two_more, mean_minus[5], mean_minus_half[5], mean_normal[5], mean_plus_half[5], mean_plus[5])
    # push!(three_more, mean_minus[6], mean_minus_half[6], mean_normal[6], mean_plus_half[6], mean_plus[6])
    # push!(rr_par_30, mean_minus[7], mean_minus_half[7], mean_normal[7], mean_plus_half[7], mean_plus[7])
    # push!(inc_fr, mean_minus[8], mean_minus_half[8], mean_normal[8], mean_plus_half[8], mean_plus[8])
    # push!(inc_ac, mean_minus[9], mean_minus_half[9], mean_normal[9], mean_plus_half[9], mean_plus[9])
    # push!(inc_sp, mean_minus[10], mean_minus_half[10], mean_normal[10], mean_plus_half[10], mean_plus[10])
    # push!(h_array, mean_minus[11], mean_minus_half[11], mean_normal[11], mean_plus_half[11], mean_plus[11])
    # push!(c_array, mean_minus[12], mean_minus_half[12], mean_normal[12], mean_plus_half[12], mean_plus[12])
    # push!(e_array, mean_minus[13], mean_minus_half[13], mean_normal[13], mean_plus_half[13], mean_plus[13])
    # push!(corr_array, mean_minus[14], mean_minus_half[14], mean_normal[14], mean_plus_half[14], mean_plus[14])

    # p9 = Plots.plot([prev_year, lifetime, one_more, two_more, three_more], xticks = (1:5, label_ticks), label = ["prevalence" "lifetime prevalence" "more after one" "more after two" "more after three"], title ="h resilience", legend = false)

    # Plots.plot(p1, p2, p3, p4, p5, p6, p7, p8, p9, layout = (@layout[a b; c d; e f; g h; i]))
end

function return_array_parts(array)
    return array[1:3], array[4:6], array[7:10], array[11:14]
end
function return_mean_100(para)


    prev_year = Float64[]
    lifetime = Float64[]
    life_1565 = Float64[]
    one_more = Float64[]
    two_more = Float64[]
    three_more = Float64[]
    rr_par_30 = Float64[]
    inc_fr = Float64[]
    inc_ac = Float64[]
    inc_sp = Float64[]
    h_array = Float64[]
    c_array = Float64[]
    e_array = Float64[]
    corr_array = Float64[]



    for i=1:100
    
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

        sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 

        results = run_sim(sim, para)

        push!(prev_year, ratedep_12month(sim))
        push!(lifetime, deprisk_life(sim))
        push!(life_1565, deprisk_life_15to65(sim))
        perc_one, perc_two, perc_three = depressive_episode_analytics(sim)
        push!(one_more, perc_one)
        push!(two_more, perc_two)
        push!(three_more, perc_three)
        push!(rr_par_30, results.rr_parents_30)
        push!(inc_fr, results.incr4_fr)
        push!(inc_ac, results.incr4_ac)
        push!(inc_sp, results.incr4_sp)

        h, c, e = heritability_calculations(sim)
        push!(h_array, h)
        push!(c_array, c)
        push!(e_array, e)

        corr = eigen_centrality(sim)
        push!(corr_array, corr)

    end

    return [mean(prev_year), mean(lifetime), mean(life_1565), mean(one_more), mean(two_more), mean(three_more), mean(rr_par_30), mean(inc_fr)-1, mean(inc_ac)-1, mean(inc_sp)-1, mean(h_array), mean(c_array), mean(e_array), mean(corr_array)], [std(prev_year), std(lifetime), std(life_1565), std(one_more), std(two_more), std(three_more), std(rr_par_30), std(inc_fr), std(inc_ac), std(inc_sp), std(h_array), std(c_array), std(e_array), std(corr_array)]

end


function intervention_analytics!()

    prev_year = Float64[]
    lifetime = Float64[]
    life_1565 = Float64[]
    one_more = Float64[]
    two_more = Float64[]
    three_more = Float64[]
    rr_par_30 = Float64[]
    inc_fr = Float64[]
    inc_ac = Float64[]
    inc_sp = Float64[]
    h_array = Float64[]
    c_array = Float64[]
    e_array = Float64[]
    corr_array = Float64[]

    para = Parameters()
    mean_normal, sd_normal = return_mean_100(para)
    mean_normal_1, mean_normal_2, mean_normal_3, mean_normal_4 = return_array_parts(mean_normal)

    # #therapy for all 
    para_therapy_all = Parameters(therapy_for_all = true)
    mean_therapy_all, sd_therapy_all = return_mean_100(para_therapy_all)

    # #therapy for lower ses 
    para_therapy_lower_ses = Parameters(therapy_for_lower_ses = true)
    mean_therapy_lower_ses, sd_therapy_lower_ses = return_mean_100(para_therapy_lower_ses)

    #prevent depressive isolation
    depr_isolation_03 = Parameters(prevent_depressive_isolation = 0.3)
    depr_isolation_05 = Parameters(prevent_depressive_isolation = 0.5)
    depr_isolation_07 = Parameters(prevent_depressive_isolation = 0.7)
    depr_isolation_1 = Parameters(prevent_depressive_isolation = 1)
    mean_isolation_03, sd_isolation_03 = return_mean_100(depr_isolation_03)
    mean_isolation_05, sd_isolation_05 = return_mean_100(depr_isolation_05)
    mean_isolation_07, sd_isolation_07 = return_mean_100(depr_isolation_07)
    mean_isolation_1, sd_isolation_1 = return_mean_100(depr_isolation_1)

    
    # #educational_support_depressed_kids
    ed_support_03 = Parameters(educational_support_depressed_kids = 0.3)
    ed_support_05 = Parameters(educational_support_depressed_kids = 0.5)
    ed_support_07 = Parameters(educational_support_depressed_kids = 0.7)
    ed_support_1 = Parameters(educational_support_depressed_kids = 1)
    mean_ed_support_03, sd_ed_support_03 = return_mean_100(ed_support_03)
    mean_ed_support_05, sd_ed_support_05 = return_mean_100(ed_support_05)
    mean_ed_support_07, sd_ed_support_07 = return_mean_100(ed_support_07)
    mean_ed_support_1, sd_ed_support_1 = return_mean_100(ed_support_1)
    
    #job_support_depressed_pop
    job_support_03 = Parameters(job_support_depressed_pop = 0.3)
    job_support_05 = Parameters(job_support_depressed_pop = 0.5)
    job_support_07 = Parameters(job_support_depressed_pop = 0.7)
    job_support_1 = Parameters(job_support_depressed_pop = 0.9)
    mean_job_support_03, sd_job_support_03 = return_mean_100(job_support_03)
    mean_job_support_05, sd_job_support_05 = return_mean_100(job_support_05)
    mean_job_support_07, sd_job_support_07 = return_mean_100(job_support_07)
    mean_job_support_1, sd_job_support_1 = return_mean_100(job_support_1)


    push!(prev_year, mean_normal[1], mean_therapy_all[1], mean_therapy_lower_ses[1], mean_isolation_1[1], mean_ed_support_1[1], mean_job_support_1[1])
    push!(lifetime, mean_normal[2], mean_therapy_all[2], mean_therapy_lower_ses[2], mean_isolation_1[2], mean_ed_support_1[2], mean_job_support_1[2])
    push!(life_1565, mean_normal[3], mean_therapy_all[3], mean_therapy_lower_ses[3], mean_isolation_1[3], mean_ed_support_1[3], mean_job_support_1[3])
    push!(one_more, mean_normal[4], mean_therapy_all[4], mean_therapy_lower_ses[4], mean_isolation_1[4], mean_ed_support_1[4], mean_job_support_1[4])
    push!(two_more, mean_normal[5], mean_therapy_all[5], mean_therapy_lower_ses[5], mean_isolation_1[5], mean_ed_support_1[5], mean_job_support_1[5])
    push!(three_more, mean_normal[6], mean_therapy_all[6], mean_therapy_lower_ses[6], mean_isolation_1[6], mean_ed_support_1[6], mean_job_support_1[6])
    push!(rr_par_30, mean_normal[7], mean_therapy_all[7], mean_therapy_lower_ses[7], mean_isolation_1[7], mean_ed_support_1[7], mean_job_support_1[7])
    push!(inc_fr, mean_normal[8], mean_therapy_all[8], mean_therapy_lower_ses[8], mean_isolation_1[8], mean_ed_support_1[8], mean_job_support_1[8])
    push!(inc_ac, mean_normal[9], mean_therapy_all[9], mean_therapy_lower_ses[9], mean_isolation_1[9], mean_ed_support_1[9], mean_job_support_1[9])
    push!(inc_sp, mean_normal[10], mean_therapy_all[10], mean_therapy_lower_ses[10], mean_isolation_1[10], mean_ed_support_1[10], mean_job_support_1[10])
    push!(h_array, mean_normal[11], mean_therapy_all[11], mean_therapy_lower_ses[11], mean_isolation_1[11], mean_ed_support_1[11], mean_job_support_1[11])
    push!(c_array, mean_normal[12], mean_therapy_all[12], mean_therapy_lower_ses[12], mean_isolation_1[12], mean_ed_support_1[12], mean_job_support_1[12])
    push!(e_array, mean_normal[13], mean_therapy_all[13], mean_therapy_lower_ses[13], mean_isolation_1[13], mean_ed_support_1[13], mean_job_support_1[13])
    push!(corr_array, mean_normal[14], mean_therapy_all[14], mean_therapy_lower_ses[14], mean_isolation_1[14], mean_ed_support_1[14], mean_job_support_1[14])
   
    label_ticks = repeat(["normal", "therapy all", "therapy ses", "isolation", "ed supp", "job supp"], outer =5)
  
    results_array= [prev_year; lifetime; one_more; two_more; three_more]
    grp = repeat(["prev year", "lifetime", "prob. more (1)", "prob. more (2)", "prob. more (3)"], inner= 6)
    StatsPlots.groupedbar(grp, results_array, group = label_ticks, bar_position=:dodge, title="analysis of intervention effects", legend =:outertopright, size=(900, 700), xlabel="observed variable", ylabel="outcome")

end


function intervention_boxplots!()

    x = []
    para = Parameters()
    para_therapy_all = Parameters(therapy_for_all = true)
    para_therapy_ses = Parameters(therapy_for_lower_ses = true)
    para_prevent_isolation = Parameters(prevent_depressive_isolation = true)
    para_job_support = Parameters(job_support_depressed_pop = true)
    para_ed_support = Parameters(educational_support_depressed_kids = true)


    for i = 1:10
        push!(x, "prev year")
    end
    for i = 1:10
        push!(x, "lifetime")
    end
    for i = 1:10
        push!(x, "recurrence 1")
    end
    for i = 1:10
        push!(x, "recurrence 2")
    end
    for i = 1:10
        push!(x, "recurrence 3")
    end

    

    trace1 = PlotlyJS.box(
    y=return_boxplots_10_rep(para),
    x=x,
    name="no intervention",
    marker_color="green"
    )
    trace2 = PlotlyJS.box(
    y=return_boxplots_10_rep(para_therapy_all),
    x=x,
    name="therapy all",
    marker_color="red"
    )
    trace3 = PlotlyJS.box(
    y=return_boxplots_10_rep(para_therapy_ses),
    x=x,
    name="therapy lower ses",
    marker_color="orange"
    )
    trace4 = PlotlyJS.box(
    y=return_boxplots_10_rep(para_prevent_isolation),
    x=x,
    name="prevent isolation",
    marker_color="black"
    )
    trace5 = PlotlyJS.box(
    y=return_boxplots_10_rep(para_ed_support),
    x=x,
    name="ed support",
    marker_color="blue"
    )
    trace6 = PlotlyJS.box(
    y=return_boxplots_10_rep(para_job_support),
    x=x,
    name="job support",
    marker_color="violet"
    )

    PlotlyJS.plot([trace1, trace2, trace3, trace4, trace5, trace6], Layout(yaxis_title="outcome measure", boxmode="group"))

end

function return_boxplots_10_rep(para)

    prev_year = Float64[]
    lifetime = Float64[]
    life_1565 = Float64[]
    one_more = Float64[]
    two_more = Float64[]
    three_more = Float64[]
    rr_par_30 = Float64[]
    inc_fr = Float64[]
    inc_ac = Float64[]
    inc_sp = Float64[]
    h_array = Float64[]
    c_array = Float64[]
    e_array = Float64[]
    corr_array = Float64[]

    for i = 1:10
        d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()

        sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids) 
        results = run_sim(sim, para)

        push!(prev_year, ratedep_12month(sim))
        push!(lifetime, deprisk_life(sim))
        perc_one, perc_two, perc_three = depressive_episode_analytics(sim)
        push!(one_more, perc_one)
        push!(two_more, perc_two)
        push!(three_more, perc_three)
    end

    
    return append!(prev_year, lifetime, one_more, two_more, three_more)
    
end
