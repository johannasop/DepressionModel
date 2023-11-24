
#Ratenberechnung zur Überprüfung
function ratedep(sim)
    counter = count(p->p.state==depressed, sim.pop)
    
    return counter/length(sim.pop)
end

function ratedep_parents(sim)
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

function ratedep_friends(sim)
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
function ratedep_ac(sim)
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

function ratedep_child(sim)
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

function ratedep_spouse(sim)
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
#    @record "prev" ratedep(sim) 
#    @record "prev parents" ratedep_parents(sim)
#    @record "prev friends" ratedep_friends(sim)
#    @record "prev ac" ratedep_ac(sim)
#    @record "prev spouse" ratedep_spouse(sim)
#    @record "prev children" ratedep_child(sim)
#    @record "avg risk" averagerisk(sim)

#end

#data = observe(Data, sim)
#print_header(stdout, Data)
#log_results(stdout, data)


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
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_none, array_health_none, c1, c2, c3, c4 = run_sim(sim, para)
    printpara!(sim)
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
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_edu, array_health_edu, c1, c2, c3, c4 = run_sim(sim, para)
    printpara!(sim)  
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
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_inc, array_health_inc, c1, c2, c3, c4 = run_sim(sim, para)
    printpara!(sim) 
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
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_both, array_health_both, c1, c2, c3, c4 = run_sim(sim, para)
    printpara!(sim)  
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

        push!(ages, person.age)
    end

    println("avg n friends: ", avg_n_friends/length(sim.pop))
    println("avg n ac: ", avg_n_ac/length(sim.pop))
    println("n parents: ", avg_n_parents/length(sim.pop)*100, " %")
    println("avg n children: ", avg_n_children/c)
    println("avg n nokids: ", avg_n_nokids/length(sim.pop)*100, " %")
    println("avg n nokids älter: ", avg_n_nokidsold/count(p->p.age>=50, sim.pop)*100, " %")
    println("avg n spouse: ", avg_n_spouse/length(sim.pop)*100, " %")
    
    #sort!(ages)
    #hier wäre ein frquency-Plot noch schön für die Altersverteilung
end