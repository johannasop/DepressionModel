

function pre_setup()

    #Erwachsenen und Kindern ein Alter zuordnen
    data_grownups = CSV.read(joinpath(@__DIR__, "pop_pyramid_2020_Erwachsene.csv"), DataFrame)
    age_data_m = data_grownups.males
    age_data_f = data_grownups.females

    data_kids = CSV.read(joinpath(@__DIR__,"pop_pyramid_2020_Kinder.csv"), DataFrame)
    age_data_kids = data_kids.males

    d_sum_m = cumsum(age_data_m)
    d_sum_f = cumsum(age_data_f)
    d_sum_kids = cumsum(age_data_kids)

    return d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids
end


# set up a mixed population
# p_contact is the probability that two agents are connected
function setup_mixed(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

    pop = SimplePerson[]
    men = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    women = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    kids = [ SimplePerson() for i=1:(para.n/5)]

    pop_potentialparents = SimplePerson[]
    pop_singles = SimplePerson[]
    pop_identical_twins = SimplePerson[]
    pop_fraternal_twins = SimplePerson[]

    for i in eachindex(men)
        r = rand() * d_sum_m[end]
        idx = searchsortedfirst(d_sum_m, r)

        men[i].age = data_grownups.age[idx]
    end

    for i in eachindex(women)
        r = rand() * d_sum_f[end]
        idx = searchsortedfirst(d_sum_f, r)

        women[i].age = data_grownups.age[idx]
    end

    for i in eachindex(kids)
        r = rand() * d_sum_kids[end]
        idx = searchsortedfirst(d_sum_kids, r)

        kids[i].age = data_kids.age[idx]
    end


    #Männern einen Bildungsstand zuweisen und diesen dann für den Rest der Familie übernehmen, außerdem Wahrscheinlichkeit sich in Therapie zu begeben
    for i in eachindex(men)
         men[i].education = rand(1:4)
         calculateincome!(men[i], para)
         men[i].gen_susceptibility_expo = [rand(Exponential(para.lambda)), rand(Exponential(para.lambda))]
         men[i].pheno_susceptibility_expo = limit(0, (para.h_expo * (sum(men[i].gen_susceptibility_expo)/2) + ((1-para.h_expo) * rand(Exponential(para.lambda)))), 100)
     
         men[i].gen_susceptibility =[rand(Normal(para.mw_h, para.b)), rand(Normal(para.mw_h, para.b))]
         men[i].pheno_susceptibility = limit(0, (para.h* sum(men[i].gen_susceptibility)/2) + ((1-para.h) * rand(Normal(para.mw_h, para.b))), 100)

         men[i].gen_resilience =[rand(Normal(para.mw_h_resilience, para.b_resilience)), rand(Normal(para.mw_h_resilience, para.b_resilience))]
         men[i].pheno_resilience = limit(0.001, (para.h_resilience* sum(men[i].gen_resilience)/2) + ((1-para.h_resilience) * rand(Normal(para.mw_h_resilience, para.b_resilience))), 100)

         setprobther!(men[i], para)
    end


    #erstelle Familien mit Partnern
    for i=1:para.n_fam
        counter = 0
        x = rand(1:length(men))
        y = rand(1:length(women))
        man = men[x]
        woman = women[y]

        while length(man.spouse) < 1
            #als Partner gegenseitig eintragen, wenn Altersunterschied ok ist, anschließend in Population einfügen
            if abs(man.age - woman.age) <= 5 && counter < 200
                add_eachother!(man, man.spouse, woman, woman.spouse)
                add_to_sc!(man, woman)
                add_to_sc!(woman, man)
            elseif counter > 200 && abs(man.age-woman.age) <= 10
                add_eachother!(man, man.spouse, woman, woman.spouse)
                add_to_sc!(man, woman)
                add_to_sc!(woman, man)
            else
                x = rand(1:length(men))
                y = rand(1:length(women))
                man = men[x]
                woman = women[y]
            end

            counter += 1
        end

        push!(pop, man)
        push!(pop, woman)
        #letzte Person auf diese Stelle kopieren und anschließend letzte Person löschen
        men[x] = last(men)
        women[y] = last(women)
        pop!(men)
        pop!(women)

        #Beziehungsdauer bestimmen und aktuelle Beziehungslänge auf zufälligen Wert innerhalb des Intervalls setzen
        man.rellength = rand(Poisson(para.durations[rand(1:length(para.durations))]))
        woman.rellength = man.rellength

        man.currdur = rand(0:man.rellength)
        woman.currdur = man.currdur


        #gleicher SÖS aber andere susceptibility
        woman.education = man.education
        calculateincome!(woman, para)
        setprobther!(woman, para)

        woman.gen_susceptibility_expo = [rand(Exponential(para.lambda)), rand(Exponential(para.lambda))]
        woman.pheno_susceptibility_expo = limit(0, (para.h_expo * (sum(woman.gen_susceptibility_expo)/2) + ((1-para.h_expo) * rand(Exponential(para.lambda)))), 100)    

        woman.gen_susceptibility = [rand(Normal(para.mw_h, para.b)), rand(Normal(para.mw_h, para.b))]
        woman.pheno_susceptibility = limit(0, (para.h* (sum(woman.gen_susceptibility)/2) + ((1-para.h) * rand(Normal(para.mw_h, para.b)))), 100)

        woman.gen_resilience = [rand(Normal(para.mw_h_resilience, para.b_resilience)), rand(Normal(para.mw_h_resilience, para.b_resilience))]
        woman.pheno_resilience = limit(0.001, (para.h_resilience* (sum(woman.gen_resilience)/2) + ((1-para.h_resilience) * rand(Normal(para.mw_h_resilience, para.b_resilience)))), 100)
    end

    #ordne Kinder diesen Partnern zu
    for kid in kids
        #hier könnte ich auch einfach Länge der Population nehmen? Bis jetzt befinden sich in dieser ja nur Paare
        parent = pop[rand(1:(para.n_fam*2))]

        #die sus der Kinder besteht zu einem Teil aus der der Eltern und zu einem Teil aus Umwelteinflüssen: Anteile können über para.h verändert werden
        kid.gen_susceptibility_expo = [rand(Exponential(para.lambda)), rand(Exponential(para.lambda))]
        kid.pheno_susceptibility_expo = limit(0, (para.h_expo * (sum(kid.gen_susceptibility_expo)/2) + ((1-para.h_expo) * rand(Exponential(para.lambda)))), 100)
    
        kid.gen_susceptibility = [rand(Normal(para.mw_h, para.b)), rand(Normal(para.mw_h, para.b))]
        kid.pheno_susceptibility = limit(0, (para.h* (sum(kid.gen_susceptibility)/2)) + ((1-para.h) * rand(Normal(para.mw_h, para.b))), 100)

        kid.gen_resilience = [rand(Normal(para.mw_h_resilience, para.b_resilience)), rand(Normal(para.mw_h_resilience, para.b_resilience))]
        kid.pheno_resilience = limit(0.001, (para.h_resilience* (sum(kid.gen_resilience)/2) + ((1-para.h_resilience) * rand(Normal(para.mw_h_resilience, para.b_resilience)))), 100)
 

        push!(pop, kid)
        add_eachother!(parent, parent.children, kid, kid.parents)

        #jeweiliger Partner wird als Elternteil eingetragen und bei diesem das Kind gespeichert
        add_eachother!(parent.spouse[1], parent.spouse[1].children, kid, kid.parents)
    end

    #finde Paare ohne Kinder und trage sie auf Liste der potentiellen Eltern ein
    for person in pop
        if length(person.children) == 0 && length(person.spouse) > 0
            push!(pop_potentialparents, person)
        end
    end

    #restlichen Frauen auch einen SÖS zuordnen und übrig Gebliebene einsortieren
    for i in eachindex(women)
        women[i].education = rand(1:4)
        calculateincome!(women[i], para)
        women[i].gen_susceptibility_expo = [rand(Exponential(para.lambda)), rand(Exponential(para.lambda))]
        women[i].pheno_susceptibility_expo = limit(0, (para.h_expo * (sum(women[i].gen_susceptibility_expo)/2) + ((1-para.h_expo) * rand(Exponential(para.lambda)))), 100)    

        women[i].gen_susceptibility = [rand(Normal(para.mw_h, para.b)), rand(Normal(para.mw_h, para.b))]
        women[i].pheno_susceptibility = limit(0, (para.h* sum(women[i].gen_susceptibility/2)) + ((1-para.h) * rand(Normal(para.mw_h, para.b))), 100)

        women[i].gen_resilience = [rand(Normal(para.mw_h_resilience, para.b_resilience)), rand(Normal(para.mw_h_resilience, para.b_resilience))]
        women[i].pheno_resilience = limit(0.001, (para.h_resilience* (sum(women[i].gen_resilience)/2) + ((1-para.h_resilience) * rand(Normal(para.mw_h_resilience, para.b_resilience)))), 100)
 
        setprobther!(women[i], para)
    end
    append!(pop_singles, men, women)
    append!(pop, men, women)


    #Bekannte und Freunde finden
    for i in eachindex(pop)
        findsocial!(pop[i], pop, para)
    end

    return pop, pop_singles, pop_potentialparents, pop_identical_twins, pop_fraternal_twins
end


function  setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    # for reproducibility
    if para.seed > 0
	    Random.seed!(para.seed)
    end

    # create a population of agents, fully mixed
    pop, pop_singles, pop_potentialparents, pop_identical_twins, pop_fraternal_twins = setup_mixed(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

    pop_depressed = SimplePerson[]
    pop_non_depressed = SimplePerson[]
    pop_currently_depressed = SimplePerson[]
    pop_dead = SimplePerson[]
    pop_therapy_all = SimplePerson[]
    pop_therapy_recurrent = SimplePerson[]

    # create a simulation object with parameter values
    sim = Simulation(pop, pop_singles, pop_potentialparents, pop_identical_twins, pop_fraternal_twins, pop_depressed, pop_non_depressed, pop_currently_depressed, pop_dead,pop_therapy_all, pop_therapy_recurrent, 0)
    sim
end