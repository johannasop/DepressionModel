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

mutable struct Parameters

    prev::Float64
    rem::Float64
    rem_ther::Float64
    avail_high::Float64
    avail_middle::Float64
    avail_low::Float64
    prev_parents::Float64
    prev_friends::Float64
    prev_ac::Float64
    prev_child::Float64
    prev_spouse::Float64
    n::Int64
    n_fam::Int64
    p_ac::Float64
    p_fr::Float64
    heritability::Float64
    n_dep::Int64
    seed::Int64

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
    if rand() < para.prev
        person.state = depressed
    end
   
    
    for p in person.parents 
        if rand(person.parents) == depressed && rand() < para.prev_parents
        person.state = depressed
        end
    end
    for p in person.children 
        if rand(person.children) == depressed && rand() < para.prev_child
        person.state = depressed
        end
    end
    for p in person.friends 
        if rand(person.friends) == depressed && rand() < para.prev_friends
        person.state = depressed
        end
    end
    if length(person.spouse) > 0 && rand(person.spouse) == depressed && rand() < para.prev_spouse
        person.state = depressed
    end
    for p in person.ac 
        if rand(person.ac) == depressed && rand() < para.prev_ac
        person.state = depressed
        end
    end

    #Spontanremmisionen 
    if person.state == depressed && rand() < para.rem
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
    if rand() < person.prob_ther && rand() < para.rem_ther
        person.state = healthy
    else
        person.prob_ther = person.prob_ther - 0.1
    end

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
         #men[i].susceptibility = rand(Normal(0.1, 0.1))
     end


    #erstelle Familien mit Partnern
    for i=1:para.n_fam

        x = rand(1:length(men))
        y = rand(1:length(women))
        man = men[x]
        woman = women[y]

        #gleicher SÖS aber andere susceptibility
        woman.ses = man.ses
        woman.susceptibility = man.susceptibility

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
        #kids[i].susceptibility = (pop[x].susceptibility) + rand(Normal(0.0, 0.1)) 


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

function  setup_sim(;prev, rem, rem_ther, avail_high, avail_middle, avail_low, prev_parents, prev_friends, prev_ac, prev_child, prev_spouse, N, n_fam, p_ac, p_friends, heritability, n_dep, seed)
    # for reproducibility
    Random.seed!(seed)

    para = Parameters(prev, rem, rem_ther, avail_high, avail_middle, avail_low, prev_parents, prev_friends, prev_ac, prev_child, prev_spouse, N, n_fam, p_ac, p_friends, heritability, n_dep, seed)

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
sim, para = setup_sim(prev = 0.08, rem = 0.51, rem_ther = 0.45, avail_high = 0.4, avail_middle = 0.25, avail_low = 0.1, prev_parents = 0.26, prev_friends = 0.24, prev_ac = 0.12, prev_child = 0.1, prev_spouse = 0.10, N = 500, n_fam = 100, p_ac = 300/1000, p_friends = 20/1000, heritability = 0.35, n_dep = 0, seed = 42)


depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, 50, para)


Plots.plot([heal, depr, healhigh, deprhigh, healmiddle, deprmiddle, heallow, deprlow], labels = ["healthy" "depressed" "healthy high ses" "depressed high ses" "healthy middle ses" "depressed middle ses" "healthy low ses" "depressed low ses"])


#Korrelation checken
#kids_sus = []
#parents_sus = []

#for i in eachindex(sim.pop)
#    if !isempty(sim.pop[i].parents)
#            push!(parents_sus, (sim.pop[i].parents[1].susceptibility+sim.pop[i].parents[2].susceptibility/2))
#            push!(kids_sus, sim.pop[i].susceptibility)
#    end
#end

#Statistics.cor(kids_sus, parents_sus)



#für jede Person Anzahl der Kontakte, SÖS usw. ausgeben
#for i in eachindex(sim.pop)
#    print("\n", i, " SÖS: ", sim.pop[i].ses, " Anzahl der Kontakte: ", length(sim.pop[i].parents) + length(sim.pop[i].friends) + length(sim.pop[i].ac) + length(sim.pop[i].children) + length(sim.pop[i].spouse), " Zustand: ", sim.pop[i].state)
#end



#Variablen über komplette Population ausgeben
#@observe Data model begin
#    @record "N" Int length(model.pop)
#    @record "time" model.time
#
#    @for ind in model.pop begin
#        @stat("number of depressed people", CountAcc) <| (ind.state == depressed)
#        @stat("contacts", MaxMinAcc{Float64}, MeanVarAcc{Float64}) <| convert(Float64, (length(ind.parents) + length(ind.children) + length(ind.friends) + length(ind.ac) + length(ind.spouse)))
#        
#    end
#end
#print_header(stdout, Data)




