using Random
using Plots
using DifferentialEquations
using Distributions
using CSV
using DataFrames
using MiniObserve
using Statistics
using XLSX

# all possible states a person can be in
@enum State healthy depressed
@enum SES high middle low
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
    
    ses::SES

    prob_ther::Float64
    susceptibility::Float64
    risk::Float64

end

Base.@kwdef mutable struct Parameters

    prev::Float64 = 0.1
    rem::Float64 = 0.51
    rem_ther::Float64 = 0.45
    avail_high::Float64 = 0.5
    avail_middle::Float64 = 0.2
    avail_low::Float64 = 0.1
    rate_parents::Float64 = 0.25
    rate_friends::Float64 = 0.35
    rate_ac::Float64 = 0
    rate_child::Float64 = 0
    rate_spouse::Float64 = 0
    n::Int64 = 1000
    n_fam::Int64 = 300
    p_ac::Float64 = 100/1000
    p_fr::Float64 = 30/1000
    seed::Int64 = 50

    #Breite der Verteilung der susceptibility
    b::Float64 = 0.1

    #Heritabilitätsindex(?)
    h::Float64 = 0.3

    #Resilienzfaktor?
    res::Float64 = 1.0

end
# how we construct a person object
SimplePerson() = SimplePerson([], [], [], [], [], 0, healthy, middle, 0, 0, 0)   # default Person is susceptible and has no contacts
SimplePerson(state) = SimplePerson([], [], [], [], [], 0, state, middle, 0, 0, 0)  # default Person has no contacts


# this is a parametric type
# we can specify which type AGENT is going to be replaced with
# when constructing our Simulation
mutable struct Simulation{AGENT}
    
    pop :: Vector{AGENT}

    time::Int64
end

function update!(person, sim, para)
 
    parents = findfirst(p-> p.state == depressed, person.parents) !== nothing
    friends = findfirst(p-> p.state == depressed, person.friends) !== nothing
    children = findfirst(p-> p.state == depressed, person.children) !== nothing
    ac = findfirst(p-> p.state == depressed, person.ac) !== nothing


    rate = 0
    if parents
        rate += para.rate_parents
    end

    if children 
        rate += para.rate_child
    end

    if friends
        rate += para.rate_friends
    end

    if ac 
        rate += para.rate_ac
    end

    if length(person.spouse) > 0 && person.spouse[1].state == depressed 
        rate += para.rate_spouse
    end
    
    # ich wuerde wahrscheinlich eher prev einfach zu rate addieren
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

    therapy!(person, para)
end

function therapy!(person, para)

    #Wahrscheinlichkeit sich in Therapie zu begeben in Abhängigkeit des SÖS
    if person.ses == high 
        person.prob_ther = para.avail_high
    end
    if person.ses == middle 
        person.prob_ther = para.avail_middle
    end
    if person.ses == low 
        person.prob_ther = para.avail_low
    end
    
    #Annahme, dass Therapiemotivation mit weniger Erfolg sinkt
    if rand() < person.prob_ther && rand() < ratetoprob(para.rem_ther)
        person.state = healthy
    elseif (person.prob_ther - 0.1) > 0
        person.prob_ther = person.prob_ther - 0.1
    end

end

function ratetoprob(r)

    
    return r * exp(-r)
end

function update_agents!(sim, para)
    # we need to change the order, otherwise agents at the beginning of the 
    # pop array will behave differently from those further in the back
    order = shuffle(sim.pop)
    
    for p in order
        update!(p, sim, para)
    end
end   


# set up a mixed population
# p_contact is the probability that two agents are connected
function setup_mixed(para)
    
    pop = Vector{SimplePerson}(undef, 0)
    men = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    women = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    kids = [ SimplePerson() for i=1:(para.n/5)]


    #Erwachsenen und Kindern ein Alter zuordnen
    data_grownups = CSV.read(joinpath(@__DIR__, "pop_pyramid_2020_Erwachsene.csv"), DataFrame)
    age_data_m = data_grownups.males
    age_data_f = data_grownups.females
    

    d_sum = cumsum(age_data_m)
    for i in eachindex(men)
        r = rand() * d_sum[end]
        idx = searchsortedfirst(d_sum, r)

        men[i].age = data_grownups.age[idx]
    end

    d_sum = cumsum(age_data_f)
    for i in eachindex(women)
        r = rand() * d_sum[end]
        idx = searchsortedfirst(d_sum, r)

        women[i].age = data_grownups.age[idx]
    end

    data_kids = CSV.read(joinpath(@__DIR__,"pop_pyramid_2020_Kinder.csv"), DataFrame)
    age_data_kids = data_kids.males

    d_sum = cumsum(age_data_kids)
    for i in eachindex(kids)
        r = rand() * d_sum[end]
        idx = searchsortedfirst(d_sum, r)

        kids[i].age = data_kids.age[idx]
    end


    #Männern einen SÖS zuweisen und diesen dann für den Rest der Familie übernehmen
     ses = [high, middle, low]
     for i in eachindex(men)
         men[i].ses = ses[rand(1:3)]
         men[i].susceptibility = rand(Normal(1,para.b))
     end


    #erstelle Familien mit Partnern
    for i=1:para.n_fam

        x = rand(1:length(men))
        y = rand(1:length(women))
        man = men[x]
        woman = women[y]

        #gleicher SÖS aber andere susceptibility
        woman.ses = man.ses
        woman.susceptibility = rand(Normal(1, para.b))

        #als Partner gegenseitig eintragen, anschließend in Population einfügen
        push!(man.spouse, woman)
        push!(woman.spouse, man)
        push!(pop, man)
        push!(pop, woman)
        

        #letzte Person auf diese Stelle kopieren und anschließend letzte Person löschen
        men[x] = last(men)
        women[y] = last(women)
        pop!(men)
        pop!(women)

    end

    #ordne Kinder diesen Partnern zu
    
    for i in eachindex(kids)
        x = rand(1:(para.n_fam*2))   

        #gleicher SÖS wie Eltern, susceptibility als Mittelwert der susceptibility der Eltern plus einem kleinen Wert aus Normalverteilung
        kids[i].ses = pop[x].ses 

        #die sus der Kinder besteht zu einem Teil aus der der Eltern und zu einem Teil aus Umwelteinflüssen: Anteile können über para.h verändert werden
        kids[i].susceptibility =  (para.h * ((pop[x].susceptibility + pop[x].spouse[1].susceptibility)/2) + ((1-para.h) * rand(Normal(1,para.b))))


        push!(pop, kids[i])
        push!(last(pop).parents, pop[x])
        push!(pop[x].children, last(pop))

        #jeweiliger Partner wird als Elternteil eingetragen und bei diesem das Kind gespeichert
        push!(pop[x].spouse[1].children, last(pop))
        push!(last(pop).parents, pop[x].spouse[1])
    end
    
    #restlichen Frauen auch einen SÖS zuordnen und übrig Gebliebene einsortieren
    for i in eachindex(women)
        women[i].ses = ses[rand(1:3)]
        women[i].susceptibility = rand(Normal(1,para.b))
    end
    append!(pop, men, women)
    

    # go through all combinations of agents and 
    # check if they are connected
    
    for i in eachindex(pop)
        for j in i+1:length(pop)
            if rand() < para.p_ac && !(pop[i] in pop[j].spouse) && !(pop[i] in pop[j].children) && !(pop[i] in pop[j].parents)
                push!(pop[i].ac, pop[j])
                push!(pop[j].ac, pop[i])
            elseif rand() < para.p_fr && !(pop[i] in pop[j].spouse) && !(pop[i] in pop[j].children) && !(pop[i] in pop[j].parents)
                push!(pop[i].friends, pop[j])
                push!(pop[j].friends, pop[i])
            end
           
        end
    end
      
    
    return pop
end

function  setup_sim(para)
    # for reproducibility
    Random.seed!(para.seed)

    

    # create a population of agents, fully mixed
    pop = setup_mixed(para)

    # create a simulation object with parameter values
    sim = Simulation(pop, 0)
    sim
end

function run_sim(sim, n_steps, para, verbose = false)
    # we keep track of the numbers
    n_depressed = Int[]
    n_healthy = Int[]

    n_depressed_high = Int[]
    n_healthy_high = Int[]

    n_depressed_middle = Int[]
    n_healthy_middle = Int[]

    n_depressed_low = Int[]
    n_healthy_low = Int[]

    # simulation steps
    for t in  1:n_steps
        update_agents!(sim, para)
        push!(n_depressed, count(p -> p.state == depressed, sim.pop))
        push!(n_healthy, count(p -> p.state == healthy, sim.pop))

        push!(n_depressed_high, count(p -> p.state == depressed && p.ses == high, sim.pop))
        push!(n_healthy_high, count(p -> p.state == healthy && p.ses == high, sim.pop))

        push!(n_depressed_middle, count(p -> p.state == depressed && p.ses == middle, sim.pop))
        push!(n_healthy_middle, count(p -> p.state == healthy && p.ses == middle, sim.pop))

        push!(n_depressed_low, count(p -> p.state == depressed && p.ses == low, sim.pop))
        push!(n_healthy_low, count(p -> p.state == healthy && p.ses == low, sim.pop))
        # a bit of output
        if verbose
            println(t, ", ", n_depressed[end], ", ", n_healthy[end])
        end
        sim.time = sim.time + 1
        #data = observe(Data, sim)
        #log_results(stdout, data)

    end
    
    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_depressed./n, n_healthy./n , n_depressed_high./n, n_healthy_high./n, n_depressed_middle./n, n_healthy_middle./n,  n_depressed_low./n, n_healthy_low./n
end












#Ratenberechnung zur Überprüfung
function ratedep(sim)
    counter = count(p->p.state==depressed, sim.pop)
    return counter/length(sim.pop)
end

function ratedep_parents(sim)
    popcounter_parents = 0
    deprcounter_parents = 0

    for p in sim.pop 
        
        de = false
        for i in p.parents 
            if i.state == depressed
                de = true
            end
        end

        if de
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
       
        de = false
        for i in p.friends 
            if i.state == depressed
                de = true
            end
        end

        if de
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

        de = false
        for i in p.ac 
            if i.state == depressed
                de = true
            end
        end

        if de
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
       
        de = false
        for i in p.children
            if i.state == depressed
                de = true
            end
        end

        if de
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

        de = false
        for i in p.spouse
            if i.state == depressed
                de = true
            end
        end

        if de
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




function evaluationrr(sim, data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch)
    #Evaluation der Risk Ratios
    rr_par, rr_fr, rr_ac, rr_sp, rr_ch = toriskratio(sim) 

    #meansquaredistance
    return ((data_rr_par - rr_par)^2 + (data_rr_fr - rr_fr)^2 ) /2
end

function evaluationrates(sim, data_prev, data_rate_parents, data_rate_friends, data_rate_ac, data_rate_children, data_rate_spouse)
    #Evaluation der Raten
    return ((data_prev - ratedep(sim))^2 + (data_rate_parents-ratedep_parents(sim))^2 + (data_rate_friends - ratedep_friends(sim))^2 + (data_rate_ac-ratedep_ac(sim))^2 + (data_rate_spouse - ratedep_spouse(sim))^2 )/5

end




function eval_rr_multipleseeds(data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch, new_paras)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = rand(1:100)
        sim = setup_sim(new_paras)
        run_sim(sim, 50, new_paras)

        meanfit = meanfit + evaluationrr(sim, data_rr_par, data_rr_fr, data_rr_ac, data_rr_sp, data_rr_ch)
    end

    return meanfit/5
end

function eval_rates_multipleseeds(data_prev, data_rate_par, data_rate_fr, data_rate_ac, data_rate_sp, data_rate_ch, new_paras)
    meanfit = 0.0

    for i=1:5
        new_paras.seed = rand(1:100)
        sim = setup_sim(new_paras)
        run_sim(sim, 50, new_paras)

        meanfit = meanfit + evaluationrates(sim, data_prev, data_rate_par, data_rate_fr, data_rate_ac, data_rate_sp, data_rate_ch)
    end

    return meanfit/5
end


#systematische Variation von Parameterwerten
function sensi!()

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
                    sim = setup_sim(para)
                    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, 50, para)
                    push!(placeholder, ratedep(sim), ratedep_parents(sim), ratedep_friends(sim), ratedep_ac(sim), ratedep_child(sim), ratedep_spouse(sim))
            end
            push!(df, placeholder)
            placeholder = Vector{Float64}(undef, 0)
        end
    end
    CSV.write("Sensibilitätsanalyse.csv", df)

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

function randpara()

    return Parameters(prev = rand(), rate_parents= rand(), rate_friends=rand(), rate_ac = 0, rate_child = rand(), rate_spouse = 0, h= rand(), b=0.1, p_ac = rand(1:1000)/1000)

end

function approximation(steps, npoints=600) 

    pq_rates = Paraqualityrates[]
    pq_rr = Paraqualityrr[]
    quality_array = Float64[]


    for i=1:npoints
	    print(".")
        new_paras = randpara()

        qual_rr_new_paras = eval_rr_multipleseeds(2.5, 3.5, 1.2, 1.2, 1.5, new_paras)
        qual_rates_new_paras = eval_rates_multipleseeds(0.08, 0.26, 0.32, 0.12, 0.12, 0.26, new_paras)

        push!(pq_rr, Paraqualityrr(new_paras, qual_rr_new_paras)) 
        push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))
    end
    
    println()

    for i=1:steps
        sort!(pq_rr, by=p->p.quality)
        sort!(pq_rates, by=p->p.quality)

        push!(quality_array, pq_rr[1].quality)
        println(pq_rates[1].quality)
        println(pq_rates[2].quality)
        println(pq_rates[3].quality)
        
        # das zuerst, sonst werden die neuen Punkte direkt wieder entfernt
        for i=1:(npoints ÷ 2)
            pop!(pq_rr)
            pop!(pq_rates)
        end

        for i=1:(npoints ÷ 2)
            new_paras = randpara()

            qual_rr_new_paras = eval_rr_multipleseeds(2.5, 3.5, 1.2, 1.2, 1.2, new_paras)
            qual_rates_new_paras = eval_rates_multipleseeds(0.08, 0.26, 0.32, 0.12, 0.12, 0.26, new_paras)

            push!(pq_rr, Paraqualityrr(new_paras, qual_rr_new_paras)) 
            push!(pq_rates, Paraqualityrates(new_paras, qual_rates_new_paras))
        end
        println("step $i")

    end 

    sort!(pq_rr, by=p->p.quality)
    sort!(pq_rates, by=p->p.quality)

    present_optimalsolution(pq_rr, pq_rates)

    return quality_array

end


function present_optimalsolution(pq_rr, pq_rates)
    sim = setup_sim(pq_rr[1].parameters)
    run_sim(sim, 50, pq_rr[1].parameters)

    sim2= setup_sim(pq_rates[1].parameters)
    run_sim(sim2, 50, pq_rates[1].parameters)

    print("die optimalen Parameter (RR) sind Folgende: ", pq_rr[1].parameters, "\n")
    printpara!(sim)
    print("die optimalen Parameter (rates) sind Folgende: ", pq_rates[1].parameters, "\n")
    printpara!(sim2)
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

function standard!()
    para = Parameters()
    sim = setup_sim(para)
    depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, 50, para)
    printpara!(sim)
    # angenommen, dass Möglichkeit zur Therapie von SÖS abhängt
    #Plots.plot([heal, depr, healhigh, deprhigh, healmiddle, deprmiddle, heallow, deprlow], labels = ["healthy" "depressed" "healthy high ses" "depressed high ses" "healthy middle ses" "depressed middle ses" "healthy low ses" "depressed low ses"])
end



qual = approximation(10)
Plots.plot([qual], labels=["Qualität der Approximation"])

#standard!()
#sensi!()

