
#Ratenberechnung zur Überprüfung
function ratedep_12month(sim)
    counter = count(p->p.state==depressed, sim.pop)
    
    return counter/length(sim.pop)
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

depr_ratio(ctr) = ctr.depr / ctr.pop

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
function increasedrisks(former_risk_children, former_risk_friends, former_risk_ac, former_risk_parents, former_risk_spouse, par_t0, fri_t4, ac_t4, sp_t4, ch_t0, sim)

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


    return (increased_risk_parents_4 = (current_risk_children/former_risk_children), 
	    increased_risk_friends_4 = (current_risk_friends/former_risk_friends), 
	    increased_risk_ac_4 = (current_risk_ac/former_risk_ac), 
	    increased_risk_children_4 = (current_risk_parents/former_risk_parents), 
	    increased_risk_spouse_4 = (current_risk_spouse/former_risk_spouse))
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
    return depr_ratio(ctr_depkids) / depr_ratio(ctr_nondepkids)
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
         elseif person.state == healthy
             h_count +=1
             avg_h += person.income
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
    println("increased risk if parent is depressed 4 years later: ", results.increased_risk_parents_4 - 1)
    println("** increased risk if friend is depressed 4 years later: ", results.increased_risk_friends_4 - 1)
    println("** increased risk if ac is depressed 4 years later: ", results.increased_risk_ac_4 - 1)
    println("** increased risk if spouse is depressed 4 years later: ", results.increased_risk_spouse_4 - 1)
    println("increased risk if child is depressed 4 years later: ", results.increased_risk_children_4 - 1)
    println(" ")
    h, c, e = heritability_calculations(sim)
    println("Heritabilitätsschätzer: ")
    println("** h: ", h)
    println("c: ", c)
    println("e: ", e)
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
        push!(df_all_params, [round(ratedep_12month(sim), digits = 2) round(deprisk_life_15to65(sim), digits = 2) round(deprisk_life(sim), digits = 2) round(results.rr_parents_30, digits = 2) round(results.increased_risk_friends_4, digits = 2) round(results.increased_risk_ac_4, digits = 2) round(results.increased_risk_spouse_4, digits = 2) round(h, digits = 2) round(q, digits = 5)])        

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

    adj = adjacency_matrix(G)
    gplot(G)
end