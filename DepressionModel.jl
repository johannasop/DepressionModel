using Random
using Plots
using DifferentialEquations
using Distributions
using CSV
using DataFrames
using MiniObserve
using Statistics
using AlgebraOfGraphics

include("parameters.jl") 
include("analytics.jl")
include("calibration.jl")

# all possible states a person can be in
@enum State healthy depressed
# this is our agent type
mutable struct SimplePerson
    
    # contacts
    friends :: Vector{SimplePerson}
    parents :: Vector{SimplePerson}
    children :: Vector{SimplePerson}
    # warum ein Vector?
    spouse :: Vector{SimplePerson}
    ac :: Vector{SimplePerson}

    # age
    age::Int64
    # state the person is in 
    state::State
    
    # 1 -> kein Schulabschluss, 2 -> Schulabschluss, 3 -> Ausbildung, 4-> Studium
    education::Int64
    # Skala von 0 bis 100
    income::Float64
   

    prob_ther::Float64
    susceptibility::Float64
    risk::Float64

    #estimated length of current relationship and current duration
    rellength::Int64
    currdur::Int64

    #death this year
    deathinyear::Int64

end


# how we construct a person object
SimplePerson() = SimplePerson([], [], [], [], [], 0, healthy, 0, 0, 0, 0, 0, 0, 0, 0)   # default Person is susceptible and has no contacts
SimplePerson(state) = SimplePerson([], [], [], [], [], 0, state, 0, 0, 0, 0, 0, 0, 0, 0)  # default Person has no contacts


# this is a parametric type
# we can specify which type AGENT is going to be replaced with
# when constructing our Simulation
mutable struct Simulation{AGENT}
    
    pop :: Vector{AGENT}

    pop_singles :: Vector{AGENT}
    pop_potentialparents :: Vector{AGENT}

    time::Int64
end

function update!(person, sim, para, ther_restriction, fdbck_education, fdbck_income_depression)
 
    death = population_update(person, sim, para, fdbck_education, fdbck_income_depression)

    #Person sollte dann auch niemanden mehr anstecken können
    if death
        return
    end

    rate = 0

    if (findfirst(p-> p.state == depressed, person.parents) !== nothing)
        rate += para.rate_parents
    end

    if (findfirst(p-> p.state == depressed, person.children) !== nothing) 
        rate += para.rate_child
    end

    if (findfirst(p-> p.state == depressed, person.friends) !== nothing)
        percentage = count(p -> p.state == depressed, person.friends)/length(person.friends)

        rate += para.rate_friends * percentage
    end

    if (findfirst(p-> p.state == depressed, person.ac) !== nothing)
        rate += para.rate_ac
    end

    if length(person.spouse) > 0 && person.spouse[1].state == depressed 
        rate += para.rate_spouse
    end
    
    if rate == 0
        rate += para.prev
    end

    person.risk = ratetoprob(rate * person.susceptibility)
    if rand() < person.risk
        person.state = depressed
    end
  
    #Spontanremmisionen 
    if rand() < ratetoprob(para.rem) && person.state == depressed 
        person.state = healthy
    end

    therapy!(ther_restriction, person, para)
end

function population_update(person, sim, para, fdbck_education, fdbck_income_depression)

    person.age += 1

    #Menschen sterben lassen: hier hab ichs noch nicht besser hingekriegt
    if person.age > 80
        return death(person, sim)
    end

    #Menschen ab 18 sind single
    if person.age == 18 
        push!(sim.pop_singles, person)
    end

    #ist die Person single? Dann bestimmte Wahrscheinlichkeit einen Partner zu finden
    if length(person.spouse) == 0 && rand() < para.findingpartner && person.age >= 18 
        newpartner!(person, sim, para)
    end

    #Wie lange läuft die Beziehung schon? Auf Trennung testen!
    if length(person.spouse) > 0
        person.currdur +=1
        if person.currdur > person.rellength
            splitup!(person, sim) 
        end
    end

    #SÖS: ergibt sich aus SÖS der Eltern, bisschen Zufall aber enthalten, da Intervall des Incomes bei Berechnung des incomes aus Bildungsstand heraus bisschen überlappt für jeden Bildungsstand
    #hier wird quasi erwarteter Bildungsstand berechnet

    #es wird vom Einkommen der wohlverdienenderen Person ausgegangen
    if person.age == 18
        if person.parents[1].income > person.parents[2].income 
            parentalincome = person.parents[1].income 
        else
            parentalincome = person.parents[2].income
        end

        #parentalincome = (person.parents[1].income + person.parents[2].income)/2

        if parentalincome >= 75
            person.education = 4
        elseif parentalincome >= 50
            person.education = 3
        elseif parentalincome >= 25
            person.education = 2
        else 
            person.education = 1
        end

        #selten auch mal bessere Bildung unabhängig vom Einkommen der Eltern

        if person.education < 4 && (rand() < para.better_edu_thanparents)
            person.education += 1
        end

    end

    #Wenn Personen in diesen Altersklassen Depressionen entwickeln, kann es sein, dass sie den "erwarteten" Bildungsstand nicht erreichen; dieser Feedbackeffekt lässt sich ausschalten

    if fdbck_education
        if person.age >= 18 && person.age <= 25 && person.state == depressed && person.education > 1
            if rand() < para.depressiondropout
                person.education = person.education - 1
            end
        end
    end

    #Einstieg ins Berufsleben
    if person.age == 25
        calculateincome!(person, para)
    end

    #Falls Depressionen im Erwachsenenalter auftreten, kann Job verloren gehen und dann verschlechtert sich finanzielle Situation
    #Feedbackeffekt Einkommensverlust bei Depressionen lässt sich ausschalten
    if fdbck_income_depression
        if person.age > 25 && person.state == depressed && person.income >= 10
            if rand() < para.depression_jobloss
                person.income = person.income - 10
            end
        end
    end

    return false
    end
function newkid!(sim, para)

    if length(sim.pop_potentialparents) == 0
        return
    end

    newkid = SimplePerson()

    #Eltern für neues Kind finden
    i = rand(1:length(sim.pop_potentialparents))
    parent = sim.pop_potentialparents[i]

    #SES und susceptibility: gleicher SES wie Eltern aber bisschen andere susceptibility
    newkid.susceptibility =  (para.h * ((parent.susceptibility + parent.spouse[1].susceptibility)/2) + ((1-para.h) * rand(Normal(1,para.b))))

    push!(newkid.parents, parent)
    push!(newkid.parents, parent.spouse[1])
    push!(parent.children, newkid)
    push!(parent.spouse[1].children, newkid)

    #neue Menschen brauchen Freunde und Bekannte, das dürfen aber nicht sie selber sein 

    number_ac = rand(Poisson(para.p_ac))
    number_fr = rand(Poisson(para.p_fr))
    while length(newkid.ac) < number_ac
        pos_ac = sim.pop[rand(1:length(sim.pop))]
        if pos_ac != newkid && !(pos_ac in newkid.parents) && !(pos_ac in newkid.ac)
            push!(pos_ac.ac, newkid)
            push!(newkid.ac, pos_ac)
        end
    end
    while length(newkid.friends) < number_fr
        pos_fr = sim.pop[rand(1:length(sim.pop))] 
        if pos_fr != newkid && !(pos_fr in newkid.parents) && !(pos_fr in newkid.ac) && !(pos_fr in newkid.friends)
            push!(pos_fr.friends, newkid)
            push!(newkid.friends, pos_fr)
        end
    end

    #werden Eltern gelöscht oder bleiben auf der Liste potentieller Eltern? Außerdem können sie mehr als drei Kinder kriegen
    if length(parent.children) > 3 

        if  rand() < (para.p_kids[3])
            sim.pop_potentialparents[i] = last(sim.pop_potentialparents)
            pop!(sim.pop_potentialparents)
            x = findfirst(x->x==parent.spouse[1], sim.pop_potentialparents)
            sim.pop_potentialparents[x] = last(sim.pop_potentialparents)
            pop!(sim.pop_potentialparents)
        end 

    elseif rand() < para.p_kids[length(parent.children)] 
        sim.pop_potentialparents[i] = last(sim.pop_potentialparents)
        pop!(sim.pop_potentialparents)
        x = findfirst(x->x==parent.spouse[1], sim.pop_potentialparents)
        sim.pop_potentialparents[x] = last(sim.pop_potentialparents)
        pop!(sim.pop_potentialparents)
    end

    push!(sim.pop, newkid)

end
function death(person, sim)

    #Sterbeprozess
    #Partner der sterbenden Person: falls vorhanden wird wieder single und von Liste potentieller Eltern entfernt, gemeinsam mit sterbender Person
    if length(person.spouse)> 0
        push!(sim.pop_singles, person.spouse[1])
        
        if person in sim.pop_potentialparents
            sim.pop_potentialparents[findfirst(x->x==person.spouse[1], sim.pop_potentialparents)] = last(sim.pop_potentialparents)
            pop!(sim.pop_potentialparents)
            sim.pop_potentialparents[findfirst(x->x==person, sim.pop_potentialparents)] = last(sim.pop_potentialparents)
            pop!(sim.pop_potentialparents)
        end

        pop!(person.spouse[1].spouse)
    else
        sim.pop_singles[findfirst(x->x==person, sim.pop_singles)] = last(sim.pop_singles)
        pop!(sim.pop_singles)
    end

    #Person muss noch von Listen aller ihr bekannten und befreundeten Personen gelöscht werden, denn hier kann kein Kontakt mehr bestehen
    if length(person.friends)>0
        for i=1:length(person.friends)
            person.friends[i].friends[findfirst(x->x==person, person.friends[i].friends)] = last(person.friends[i].friends)
            pop!(person.friends[i].friends)
        end
    end
    if length(person.ac)>0
        for i in eachindex(person.ac)
            person.ac[i].ac[findfirst(x->x==person, person.ac[i].ac)] = last(person.ac[i].ac)
            pop!(person.ac[i].ac)        
        end
    end


    #Mensch aus Population entfernen
    sim.pop[findfirst(x->x==person, sim.pop)] = last(sim.pop)
    pop!(sim.pop)

    return true
end

function newpartner!(person, sim, para)

    #solange noch kein Partner gefunden wurde, durchlaufen lassen, um aber festhängen zu vermeiden, maximal 100 mal
    counter = 0

    while length(person.spouse) == 0 && counter <= 100
        #Wahrscheinlichkeit aus dem gleichen Umfeld zu kommen, wird dann nochmal hälftig auf Freundeskreis und hälftig auf Bekanntenkreis aufgeteilt
        if rand()< para.partnersamecircle
            if rand() < 0.5 && length(person.friends)>0
                x = rand(1:length(person.friends))
                potpartner = person.friends[x]
            elseif length(person.ac)>0
                x = rand(1:length(person.ac))
                potpartner = person.ac[x]
            else
                x = rand(1:length(sim.pop_singles))
                potpartner = sim.pop_singles[x]
            end
        else
            x = rand(1:length(sim.pop_singles))
            potpartner = sim.pop_singles[x]
        end

        #Bedingungen: Partner muss single sein, der Altersunterschied darf nicht zu groß sein und der SES muss gleich sein, außerdem dürfen es nicht sie selber sein
        if length(potpartner.spouse) == 0 && ((potpartner.age - person.age) <= 5) && ((potpartner.age - person.age) >= -5) && potpartner.education == person.education && potpartner.age >= 18 && potpartner != person && !(potpartner in person.parents) && !(potpartner in person.children)

            #für beide die Beziehungsdauer bestimmen
            person.rellength = rand(Poisson(para.durations[rand(1:length(para.durations))]))
            potpartner.rellength = person.rellength
            push!(person.spouse, potpartner)
            push!(potpartner.spouse, person)

            sim.pop_singles[findfirst(x->x==person, sim.pop_singles)] = last(sim.pop_singles)
            pop!(sim.pop_singles)
            sim.pop_singles[findfirst(x->x==potpartner, sim.pop_singles)] = last(sim.pop_singles)
            pop!(sim.pop_singles)

            #sind nun keine Bekannten oder Freunde mehr
            if person in potpartner.friends
                person.friends[findfirst(x->x==potpartner, person.friends)] = last(person.friends)
                pop!(person.friends) 
                potpartner.friends[findfirst(x->x==person, potpartner.friends)] = last(potpartner.friends)
                pop!(potpartner.friends) 
                if person in potpartner.friends
                    println("spouse still in friends")
                end 
            end
            if person in potpartner.ac
                person.ac[findfirst(x->x==potpartner, person.ac)] = last(person.ac)
                pop!(person.ac) 
                potpartner.ac[findfirst(x->x==person, potpartner.ac)] = last(potpartner.ac)
                pop!(potpartner.ac) 
                if person in potpartner.ac
                    println("spouse still in ac")
                end
            end
               

            #Personen landen auf der Liste bei bestimmter Wahrscheinlichkeit: ab 55 Jahren können sie keine Kinder mehr bekommen
            if rand() > para.p_none && person.age < 55 && potpartner.age < 55
                push!(sim.pop_potentialparents, person)
                push!(sim.pop_potentialparents, potpartner)
            end
        end
        counter += 1
    end
end

function splitup!(person, sim)

    #Beziehungsparameter wieder auf 0 setzen
    person.currdur = 0
    person.spouse[1].currdur = 0

    person.rellength = 0
    person.spouse[1].rellength = 0

    #wieder auf Listen der Singles setzen und von Liste potenzieller Eltern entfernen
    push!(sim.pop_singles, person)
    push!(sim.pop_singles, person.spouse[1])

    if person in sim.pop_potentialparents
        sim.pop_potentialparents[findfirst(x->x==person, sim.pop_potentialparents)] = last(sim.pop_potentialparents)
        pop!(sim.pop_potentialparents)
        sim.pop_potentialparents[findfirst(x->x==person.spouse[1], sim.pop_potentialparents)] = last(sim.pop_potentialparents)
        pop!(sim.pop_potentialparents)
    end
   
    
    #Trennung einleiten
    pop!(person.spouse[1].spouse)
    pop!(person.spouse)

end

function calculateincome!(person, para)

    #Einkommen wird bestimmt aus Bildungsstand, aber Intervalle für jeden Bildungsstand überlappen etwas, man kann also auch in anderer Einkommenklasse landen (Normalverteilungen je Bildungsstand mit Mittelwerten bei 1 --> 13, 2 --> 38, 3 --> 63, 4--> 88 und Standardabweichung von 15)

    person.income = rand(Normal((person.education * 25) - 12, para.sd_income))

    if person.income < 0
    person.income = 0.0
    elseif person.income >100
    person.income = 100.0
    end
        
end

function therapy!(ther_restriction, person, para)

    #Wahrscheinlichkeit sich in Therapie zu begeben in Abhängigkeit des SÖS
    if ther_restriction
        if person.age >= 18
            if person.income >= 75
                person.prob_ther = para.avail_high
            elseif person.income >= 25
                person.prob_ther = para.avail_middle
            else
                person.prob_ther = para.avail_low
            end
        end
    else
        person.prob_ther = 1
    end
    
    #+Annahme, dass Therapiemotivation mit weniger Erfolg sinkt
    if rand() < person.prob_ther && rand() < ratetoprob(para.rem_ther)
        person.state = healthy
    elseif (person.prob_ther - 0.1) > 0
        person.prob_ther = person.prob_ther - 0.1
    end

end

function ratetoprob(r)
    return r * exp(-r)
end

function update_agents!(sim, para, ther_restriction, fdbck_education, fdbck_income_depression)
    # we need to change the order, otherwise agents at the beginning of the 
    # pop array will behave differently from those further in the back
    sim.pop = shuffle(sim.pop)

    i = length(sim.pop)
    
    while i > 0
        update!(sim.pop[i], sim, para, ther_restriction, fdbck_education, fdbck_income_depression)
        i -= 1
    end

    while length(sim.pop) < para.n 
        newkid!(sim, para)
    end

end   

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
    
    pop = Vector{SimplePerson}(undef, 0)
    men = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    women = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    kids = [ SimplePerson() for i=1:(para.n/5)]

    pop_potentialparents = Vector{SimplePerson}(undef, 0)
    pop_singles = Vector{SimplePerson}(undef, 0)


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


    #Männern einen Bildungsstand zuweisen und diesen dann für den Rest der Familie übernehmen
     for i in eachindex(men)
         men[i].education = rand(1:4)
         calculateincome!(men[i], para)
         men[i].susceptibility = rand(Normal(1,para.b))
     end


    #erstelle Familien mit Partnern
    for i=1:para.n_fam

        x = rand(1:length(men))
        y = rand(1:length(women))
        man = men[x]
        woman = women[y]

        while length(man.spouse) < 1
            #als Partner gegenseitig eintragen, wenn Altersunterschied ok ist, anschließend in Population einfügen
            if ((man.age - woman.age) <= 5) || ((man.age - woman.age) >= -5)
                push!(man.spouse, woman)
                push!(woman.spouse, man)
            else 
                x = rand(1:length(men))
                y = rand(1:length(women))
                man = men[x]
                woman = women[y]
            end
        end

        push!(pop, man)
        push!(pop, woman)

        #Beziehungsdauer bestimmen und aktuelle Beziehungslänge auf zufälligen Wert innerhalb des Intervalls setzen
        man.rellength = rand(Poisson(para.durations[rand(1:length(para.durations))]))
        woman.rellength = man.rellength

        man.currdur = rand(0:man.rellength)
        woman.currdur = man.currdur


        #gleicher SÖS aber andere susceptibility
        woman.education = man.education
        calculateincome!(woman, para)
        woman.susceptibility = rand(Normal(1, para.b))

        #letzte Person auf diese Stelle kopieren und anschließend letzte Person löschen
        men[x] = last(men)
        women[y] = last(women)
        pop!(men)
        pop!(women)

    end

    #ordne Kinder diesen Partnern zu
    for i in eachindex(kids)
        #hier könnte ich auch einfach Länge der Population nehmen? Bis jetzt befinden sich in dieser ja nur Paare
        x = rand(1:(para.n_fam*2))   

        #die sus der Kinder besteht zu einem Teil aus der der Eltern und zu einem Teil aus Umwelteinflüssen: Anteile können über para.h verändert werden
        kids[i].susceptibility =  (para.h * ((pop[x].susceptibility + pop[x].spouse[1].susceptibility)/2) + ((1-para.h) * rand(Normal(1,para.b))))


        push!(pop, kids[i])
        push!(kids[i].parents, pop[x])
        push!(pop[x].children, kids[i])

        #jeweiliger Partner wird als Elternteil eingetragen und bei diesem das Kind gespeichert
        push!(pop[x].spouse[1].children, kids[i])
        push!(kids[i].parents, pop[x].spouse[1])
        
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
        women[i].susceptibility = rand(Normal(1,para.b))
    end
    append!(pop_singles, men, women)
    append!(pop, men, women)


    #Bekannte und Freunde finden
    for i in eachindex(pop)
        number_ac = rand(Poisson(para.p_ac))
        number_fr = rand(Poisson(para.p_fr))
        while length(pop[i].ac) < number_ac
            pos_ac = pop[rand(1:1000)]
            #nicht sich selber als Bekannter haben, außerdem keine Duplikate
            if pos_ac != pop[i] && !(pos_ac in pop[i].parents) && !(pos_ac in pop[i].spouse) && !(pos_ac in pop[i].children) && !(pos_ac in pop[i].ac)
                push!(pos_ac.ac, pop[i])
                push!(pop[i].ac, pos_ac)
            end
           
        end
        while length(pop[i].friends) < number_fr
            pos_fr = pop[rand(1:1000)]
            #nicht sich selber als Freund haben, ebenfalls keine Duplikate
            if pos_fr != pop[i] && !(pos_fr in pop[i].ac) && !(pos_fr in pop[i].parents) && !(pos_fr in pop[i].spouse) && !(pos_fr in pop[i].children) && !(pos_fr in pop[i].friends)
                push!(pos_fr.friends, pop[i])
                push!(pop[i].friends, pos_fr)
            end
            
        end
    end


    return pop, pop_singles, pop_potentialparents
end

function  setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    # for reproducibility
    if para.seed > 0
	    Random.seed!(para.seed)
    end

    # create a population of agents, fully mixed
    pop, pop_singles, pop_potentialparents = setup_mixed(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)

    # create a simulation object with parameter values
    sim = Simulation(pop, pop_singles, pop_potentialparents, 0)
    sim
end

function run_sim(sim, para, ther_restriction, fdbck_education, fdbck_income_depression, verbose = false, n_steps = 150)
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

    # simulation steps
    for t in  1:n_steps
        update_agents!(sim, para, ther_restriction, fdbck_education, fdbck_income_depression)
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
    
    consistencycheck!(sim)

    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_depressed, n_healthy , n_depressed_high, n_healthy_high, n_depressed_middle, n_healthy_middle,  n_depressed_low, n_healthy_low, depr_income, health_income, c1, c2, c3, c4
end

function consistencycheck!(sim)

    for person in sim.pop
        for parent in person.parents
            if parent == person 
                println("inconsistent: parent is person")
            elseif parent in person.friends
                println("parent is friend")
            elseif parent in person.ac 
                println("parent is ac")
            elseif parent in person.spouse
                println("parent is spouse")
            elseif parent in person.children
                println("parent is child")
            end
            if !(person in parent.children)
                println("person not in parents children")
            end
        end
        for friend in person.friends
            if person == friend
                println("inconsistent: friend is person")
            elseif friend in person.parents
                println("friend is parent")
            elseif friend in person.spouse
                println("friend is spouse")
            elseif friend in person.ac 
                println("friend is ac")
            elseif friend in person.children
                println("friend is child")
            end
            if !(person in friend.friends)
                println("person not in friends friends")
            end
        end
        for ac in person.ac
            if person == ac
                println("inconsistent: ac is person")
            elseif ac in person.friends
                println("ac is friend")
            elseif ac in person.parents
                println("ac is parent")
            elseif ac in person.spouse
                println("ac is spouse")
            elseif ac in person.children
                println("ac is child")
            end
            if !(person in ac.ac)
                println("person not in ac ac")
            end
        end
        for child in person.children
            if person == child 
                println("inconsistent: person is child")
            elseif child in person.friends
                println("child is friend")
            elseif child in person.ac 
                println("child is ac")
            elseif child in person.spouse
                println("child is spouse")
            elseif child in person.parents
                println("child is parent")
            end
            if !(person in child.parents)
                println("person not in childrens parents")
            end
        end
        for spouse in person.spouse
            if person == spouse 
                println("inconsistent: person is spouse")
            elseif spouse in person.friends
                println("spouse is friend")
            elseif spouse in person.ac 
                println("spouse is ac")
            elseif spouse in person.parents
                println("spouse is parent")
            elseif spouse in person.children
                println("spouse is child")
            end
            if !(person in spouse.spouse)
                println("person not in spouses spouse")
            end
        end
    end



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
function standard!(ther_restriction, fdbck_education, fdbck_income)
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr, array_health, c1, c2, c3, c4 = run_sim(sim, para, ther_restriction, fdbck_education, fdbck_income)
    printpara!(sim)

    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, fdbck_education, fdbck_income) 
    println("Qualität der aktuellen Lösung: ", qual_rates_currentsolution)

    #Plots.plot([c1, c2, c3, c4], labels =["1" "2" "3" "4"])

    #Plots.plot([array_depr, array_health], labels = ["depressed: average income" "healthy: average income"])
    
    #Plots.plot([heal, depr, healhigh, deprhigh, healmiddle, deprmiddle, heallow, deprlow], labels = ["healthy" "depressed" "healthy high ses" "depressed high ses" "healthy middle ses" "depressed middle ses" "healthy low ses" "depressed low ses"])
end

function comparison_feedback!(ther_restriction)
    #alle Feedbackeffekte aus
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_none, array_health_none, c1, c2, c3, c4 = run_sim(sim, para, ther_restriction, false, false)
    printpara!(sim)
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1*100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2*100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3*100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4*100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, false, false)
    println("Qualität der aktuellen Lösung: keine Feedbackeffekte ", qual_rates_currentsolution)
    

    #Bildungsfeedbackeffekt an
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_edu, array_health_edu, c1, c2, c3, c4 = run_sim(sim, para, ther_restriction, true, false)
    printpara!(sim)  
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1*100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2*100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3*100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4*100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids,ther_restriction, true, false)
    println("Qualität der aktuellen Lösung: Bildungseffekt an ", qual_rates_currentsolution)
    

    #Einkommen-Depressionsfeedbackeffekt an
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_inc, array_health_inc, c1, c2, c3, c4 = run_sim(sim, para, ther_restriction, false, true)
    printpara!(sim) 
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1*100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2*100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3*100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4*100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, false, true)
    println("Qualität der aktuellen Lösung: Einkommenseffekt an ", qual_rates_currentsolution)
    

    #beide Feedbackeffekte an
    d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids = pre_setup()
    para = Parameters()
    sim = setup_sim(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids)
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow, array_depr_both, array_health_both, c1, c2, c3, c4 = run_sim(sim, para,ther_restriction, true, true)
    printpara!(sim)  
    c1, c2, c3, c4 = educationlevels(sim)
    println("Level 1: ", c1, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 1, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 1, sim.pop)/c1 *100)
    println("Level 2: ", c2, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 2, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 2, sim.pop)/c2 *100)
    println("Level 3: ", c3, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 3, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 3, sim.pop)/c3 *100)
    println("Level 4: ", c4, " Davon depressiv: ", count(p -> p.state == depressed && p.education == 4, sim.pop), " Prozentual: ", count(p -> p.state == depressed && p.education == 4, sim.pop)/c4 *100)


    qual_rates_currentsolution = eval_rates_multipleseeds(para, d_sum_m, d_sum_f, d_sum_kids, data_grownups, data_kids, ther_restriction, true, true) 
    println("Qualität der aktuellen Lösung: beide Feedbackeffekte an ", qual_rates_currentsolution)
    


    Plots.plot([array_depr_none, array_health_none, array_depr_edu, array_health_edu, array_depr_inc, array_health_inc, array_depr_both, array_health_both], labels = ["depressed: none" "healthy: none" "depressed: edu" "healthy: edu" "depressed: inc" "healthy: inc" "depressed: both" "healthy: both"])

    #Plots.plot([array_depr_none, array_health_none], labels = ["depressed: none" "healthy: none"])
    #Plots.plot([array_depr_edu, array_health_edu], labels = ["depressed: edu" "healthy: edu" ])
    #Plots.plot([array_depr_inc, array_health_inc], labels = [ "depressed: inc" "healthy: inc" ])
    #Plots.plot([array_depr_both, array_health_both], labels = [ "depressed: both" "healthy: both"])

end

function quality_plots!(fdbck_education, fdbck_income)
    qual_parent, parameter_field, lowpar = quality_function_para("parent", ther_restriction, fdbck_education, fdbck_income)
    qual_friends, parameter_field, lowfr= quality_function_para("friends", ther_restriction, fdbck_education, fdbck_income)
    qual_spouse, parameter_field, lowsp = quality_function_para("spouse", ther_restriction, fdbck_education, fdbck_income)
    qual_child, parameter_field, lowch= quality_function_para("child", ther_restriction, fdbck_education, fdbck_income)
    qual_ac, parameter_field, lowac = quality_function_para("ac", ther_restriction, fdbck_education, fdbck_income)
    qual_prev, parameter_field, lowprev = quality_function_para("prev", ther_restriction, fdbck_education, fdbck_income)
    qual_h, parameter_field, lowh = quality_function_para("h", ther_restriction, fdbck_education, fdbck_income)

    Plots.plot([qual_parent, qual_friends, qual_spouse, qual_child, qual_ac, qual_prev, qual_h], labels = ["mA Eltern" "mA Freunde" "mA spouse" "mA Kind" "mA ac" "mA prev" "mA h"], x = [parameter_field])
    
    #println("lowest parent ", lowpar)
    #println("lowest friends ", lowfr)
    #println("lowest spouse ", lowsp)
    #println("lowest child ", lowch)
    #println("lowest ac ", lowac)
    #println("lowest prev ", lowprev)
    #println("lowest h ", lowh)
end

#qual = approximation_rates(50, true, true, false) 
#Plots.plot([qual], labels=["mittlere Abweichung"]) 

#qual= optimization_current_para(50, true, false, false)
#Plots.plot([qual], labels=["mittlere Abweichung"]) 


#hier kann sich ein Graph ausgegeben werden, bei dem geschaut wird, wie sich die Qualität der Simulation über den Bereich des Parameters entwickelt
#mögliche Eingaben= "parent" "friends" "spouse" "child" "ac" "prev" "h"
#quality_plots!(false, false)
#qual_h, parameter_field= quality_function_para("h", true, true)
#Plots.plot([qual_h], labels = ["mA h"], x = [parameter_field])

#standard!(true, false, false)

#sensi!()
df = qual_sensi()


df_par_fr = data(df) * mapping(:par, :fr)
axis = (type = Axis3, width = 300, height = 300)
plt = df_par_fr * linear() * mapping(qual)
draw(plt; axis = axis)

#comparison_feedback!(false)

#qual, qual_random = params_with_multipleseeds(true, false, false)
#Plots.plot([qual, qual_random], labels=["Qualität bei unterschiedlichem Seed: beste Para" "Zufallspara"])