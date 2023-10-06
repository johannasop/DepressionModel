
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
