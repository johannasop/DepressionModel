using Random
using Plots
using DifferentialEquations
using Distributions
using CSV
using DataFrames
using MiniObserve
using Statistics

# all possible states a person can be in
@enum State healthy depressed
@enum SES high middle low
# this is our agent type
mutable struct SimplePerson
    
    # contacts
    friends :: Vector{SimplePerson}
    parents :: Vector{SimplePerson}
    children :: Vector{SimplePerson}
    spouse :: Vector{SimplePerson}
    ac :: Vector{SimplePerson}

    # age
    age::Int64
    # state the person is in 
    state::State
    
    ses::SES

    prob_ther::Float64
    susceptibility::Float64

end

Base.@kwdef mutable struct Parameters

    prev::Float64 = 0.08
    rem::Float64 = 0.51
    rem_ther::Float64 = 0.45
    avail_high::Float64 = 0.5
    avail_middle::Float64 = 0.2
    avail_low::Float64 = 0.1
    f_parents::Float64 = 2.38
    f_friends::Float64 = 4.5
    f_ac::Float64 = 1.5
    f_child::Float64 = 1.25
    f_spouse::Float64 = 1.5
    n::Int64 = 1000
    n_fam::Int64 = 300
    p_ac::Float64 = 300/1000
    p_fr::Float64 = 10/1000
    seed::Int64 = 42

    #Breite der Verteilung der susceptibility
    b::Float64 = 0.1

    #Heritabilitätsindex(?)
    h::Float64 = 0.4

    #Resilienzfaktor: nur eine grobe Überlegung: 1 bedeutet kein Einfluss
    res::Float64 = 1.0

end
# how we construct a person object
SimplePerson() = SimplePerson([], [], [], [], [], 0, healthy, middle, 0, 0)   # default Person is susceptible and has no contacts
SimplePerson(state) = SimplePerson([], [], [], [], [], 0, state, middle, 0, 0)  # default Person has no contacts


# this is a parametric type
# we can specify which type AGENT is going to be replaced with
# when constructing our Simulation
mutable struct Simulation{AGENT}
    
    pop :: Vector{AGENT}

    time::Int64
end

function update!(person, sim, para)
   #die Update-Funktion sieht ganz anders aus, weil ich einen Fehler bemerkt habe: bei der vorherigen Ansteckung wurde nie über .state der Status
   #abgefragt, sondern ungefähr so: if person == depressed 
   #daher gab es nie eine Ansteckung! Bei der Änderung habe ich gesehen, dass das Risiko massiv überschätzt wird (80% wurden depressiv)
   #deshalb wird nun geschaut: gibt es in dieser Gruppe eine depressive Person? wenn über mehrere Gruppen, dann wird das Risiko gemittelt
    parents = []
    friends = []
    children = []
    ac = []

    for p in person.parents 
       push!(parents, p.state)
    end
    for p in person.children 
        push!(children, p.state)
    end
    for p in person.friends 
        push!(friends, p.state)
    end
    for p in person.ac 
        push!(ac, p.state)
    end

    rate = 0
    if depressed in parents 
        rate += para.prev * para.f_parents
    else
        #noch unsicher, ob es sinnvoller ist hier die Prävalenz einzufügen, oder zu sagen: jeder, der keine depressiven Eltern hat, hat ein GERINGERES Risiko und ist quasi resilienter: kann oben über para.res angepasst werden
        rate += (para.prev/para.res)
    end

    if depressed in children 
        rate += para.prev * para.f_child
    else 
        rate += para.prev
    end

    if depressed in friends 
        rate += para.prev * para.f_friends
    else
        rate += (para.prev/para.res)
    end

    if depressed in ac  
        rate += para.prev * para.f_ac
    else
        rate += (para.prev)
    end

    if length(person.spouse) > 0 && person.spouse[1].state == depressed 
        rate += para.prev * para.f_spouse
    else
        rate += (para.prev)
    end

    if rand() < ratetoprob((rate/5) * person.susceptibility)
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
    
    pop = []
    men = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    women = [ SimplePerson() for i=1:(para.n/2-para.n/10)]
    kids = [ SimplePerson() for i=1:(para.n/5)]


    #Erwachsenen und Kindern ein Alter zuordnen
    data_grownups = CSV.read(joinpath(@__DIR__, "pop_pyramid_2020_Erwachsene.csv"), DataFrame)
    age_data_m = data_grownups.males
    age_data_f = data_grownups.females
    

    d_sum = cumsum(age_data_m)
    for i in eachindex(men)
        r = rand(1:d_sum[end])
        idx = searchsortedfirst(d_sum, r)

        men[i].age = data_grownups.age[idx]
    end

    d_sum = cumsum(age_data_f)
    for i in eachindex(women)
        r = rand(1:d_sum[end])
        idx = searchsortedfirst(d_sum, r)

        women[i].age = data_grownups.age[idx]
    end

    data_kids = CSV.read(joinpath(@__DIR__,"pop_pyramid_2020_Kinder.csv"), DataFrame)
    age_data_kids = data_kids.males

    d_sum = cumsum(age_data_kids)
    for i in eachindex(kids)
        r = rand(1:d_sum[end])
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

function  setup_sim()
    para = Parameters()
    # for reproducibility
    Random.seed!(para.seed)

    

    # create a population of agents, fully mixed
    pop = setup_mixed(para)

    # create a simulation object with parameter values
    sim = Simulation(pop, 0)
    sim, para
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




# angenommen, dass Möglichkeit zur Therapie von SÖS abhängt
sim, para = setup_sim()

depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, 50, para)


Plots.plot([heal, depr, healhigh, deprhigh, healmiddle, deprmiddle, heallow, deprlow], labels = ["healthy" "depressed" "healthy high ses" "depressed high ses" "healthy middle ses" "depressed middle ses" "healthy low ses" "depressed low ses"])
