using Random
using Plots
using DifferentialEquations
using Distributions

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
end

# how we construct a person object
SimplePerson() = SimplePerson([], [], [], [], [], 0, healthy, middle)   # default Person is susceptible and has no contacts
SimplePerson(state) = SimplePerson([], [], [], [], [], 0, state, middle)  # default Person has no contacts


# this is a parametric type
# we can specify which type AGENT is going to be replaced with
# when constructing our Simulation
mutable struct Simulation{AGENT}
    # model parameters:
    # 12-month prevalence 
    prev :: Float64
    # spontaneous remission rate
    rem :: Float64
    # remission rate with therapy
    rem_ther :: Float64
    # availability of therapy
    avail_high :: Float64
    avail_middle :: Float64
    avail_low :: Float64
    # risk of transmission parents
    prev_parents :: Float64
    # risk of transmission children
    prev_child :: Float64
    # risk of transmission friends
    prev_friends :: Float64
    # risk of transmission spouse
    prev_spouse :: Float64
    # risk of transmission acquaintance
    prev_ac :: Float64

    # and this is our population of agents
    pop :: Vector{AGENT}
end

function update!(person, sim)
    if rand() < sim.prev
        person.state = depressed
    end
    if person.state == depressed && rand() < sim.rem
        person.state = healthy
    end
    
    
    for p in person.parents 
        if rand(person.parents) == depressed && rand() < sim.prev_parents
        person.state = depressed
        end
    end
    for p in person.children 
        if rand(person.children) == depressed && rand() < sim.prev_child
        person.state = depressed
        end
    end
    for p in person.friends 
        if rand(person.friends) == depressed && rand() < sim.prev_friends
        person.state = depressed
        end
    end
    if length(person.spouse) > 0 && rand(person.spouse) == depressed && rand() < sim.prev_spouse
        person.state = depressed
    end
    for p in person.ac 
        if rand(person.ac) == depressed && rand() < sim.prev_ac
        person.state = depressed
        end
    end
    
    #Therapie
    therapy!(person)
end

function therapy!(person)
    if person.ses == high && rand()<sim.avail_high
        if rand() < sim.rem_ther 
            person.state = healthy
        end
    end
    if person.ses == middle && rand()<sim.avail_middle
        if rand() < sim.rem_ther 
            person.state = healthy
        end
    end
    if person.ses == low && rand()<sim.avail_low
        if rand() < sim.rem_ther 
            person.state = healthy
        end
    end


end

function update_agents!(sim)
    # we need to change the order, otherwise agents at the beginning of the 
    # pop array will behave differently from those further in the back
    order = shuffle(sim.pop)
    
    for p in order
        update!(p, sim)
    end
end   


# set up a mixed population
# p_contact is the probability that two agents are connected
function setup_mixed(n, n_fam, p_ac, p_fr)
    
    pop = []
    men = [ SimplePerson() for i=1:(n/2-n/10)]
    women = [ SimplePerson() for i=1:(n/2-n/10)]
    kids = [ SimplePerson() for i=1:(n/5)]

    #erstelle Familien mit Partnern
    for i=1:n_fam

        x = rand(1:length(men))
        y = rand(1:length(women))
        man = men[x]
        woman = women[y]

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
    
    for i=1:trunc(Int, n/5)
        x = rand(1:(n_fam*2))   

        push!(pop, kids[i])
        push!(last(pop).parents, pop[x])
        push!(pop[x].children, last(pop))

        #jeweiliger Partner wird als Elternteil eingetragen und bei diesem das Kind gespeichert
        push!(pop[x].spouse[1].children, last(pop))
        push!(last(pop).parents, pop[x].spouse[1])
    end
    
    #übrig Gebliebene einsortieren
    append!(pop, men, women)
    
    # go through all combinations of agents and 
    # check if they are connected
    
    for i in eachindex(pop)
        for j in i+1:length(pop)
            if rand() < p_ac
                push!(pop[i].ac, pop[j])
                push!(pop[j].ac, pop[i])
            elseif rand() < p_fr
                push!(pop[i].friends, pop[j])
                push!(pop[j].friends, pop[i])
            end
           
        end
    end


    # Alterszuweisung: elegantere Umsetzung
    #d_sum = cumsum(d)
    #r = rand(d_sum[end])
    #idx = searchsortedfirst(d_sum, r) #damit gewichtetes Element

    #vorherige Alterszuweisung
    for i in eachindex(pop)
        x = rand(0:100)

        if x > 75.5
            pop[i].age = rand(60:100)
        end
        if x > 49.2 && x <= 75.5
            pop[i].age = rand(40:59)
        end
        if x > 29 && x <= 49.2
            pop[i].age = rand(25:39)
        end
        if x > 20.7 && x <= 29
            pop[i].age = rand(18:24)
        end
        if x > 0 && x <= 20.7
            pop[i].age = rand(0:17)
        end
      
    end

    #SÖS zuweisen
    ses = [high, middle, low]
    for i in eachindex(pop)
        pop[i].ses = ses[rand(1:3)]
    end
    return pop
end

function  setup_sim(;prev, rem, rem_ther, avail_high, avail_middle, avail_low, prev_parents, prev_friends, prev_ac, prev_child, prev_spouse, N, n_fam, p_ac, p_friends, n_dep, seed)
    # for reproducibility
    Random.seed!(seed)

    # create a population of agents, fully mixed
    pop = setup_mixed(N, n_fam, p_ac, p_friends)

    # create a simulation object with parameter values
    sim = Simulation(prev, rem, rem_ther, avail_high, avail_middle, avail_low, prev_parents, prev_child, prev_friends, prev_spouse, prev_ac, pop)
    
            #for i in 1:n_dep --> brauche ich doch eigentlich nicht, weil man sich nicht anstecken MUSS
                # one percent of agents are "infected"
                # sim.pop[i].state = depressed
            #end
            
    sim
end

function run_sim(sim, n_steps, verbose = false)
    # we keep track of the numbers
    n_depressed = Int[]
    n_healthy = Int[]

    # simulation steps
    for t in  1:n_steps
        update_agents!(sim)
        push!(n_depressed, count(p -> p.state == depressed, sim.pop))
        push!(n_healthy, count(p -> p.state == healthy, sim.pop))
        # a bit of output
        if verbose
            println(t, ", ", n_depressed[end], ", ", n_healthy[end])
        end
    end
    
    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_depressed./n, n_healthy./n
end

function run_sim_lowses(sim, n_steps, verbose = false)
    # we keep track of the numbers
    n_depressed = Int[]
    n_healthy = Int[]

    # simulation steps
    for t in  1:n_steps
        update_agents!(sim)
        push!(n_depressed, count(p -> (p.state == depressed && p.ses == low), sim.pop))
        push!(n_healthy, count(p -> (p.state == healthy && p.ses == low), sim.pop))
        # a bit of output
        if verbose
            println(t, ", ", n_depressed[end], ", ", n_healthy[end])
        end
    end
    
    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_depressed./n, n_healthy./n
end
function run_sim_middleses(sim, n_steps, verbose = false)
    # we keep track of the numbers
    n_depressed = Int[]
    n_healthy = Int[]

    # simulation steps
    for t in  1:n_steps
        update_agents!(sim)
        push!(n_depressed, count(p -> (p.state == depressed && p.ses == middle), sim.pop))
        push!(n_healthy, count(p -> (p.state == healthy && p.ses == middle), sim.pop))
        # a bit of output
        if verbose
            println(t, ", ", n_depressed[end], ", ", n_healthy[end])
        end
    end
    
    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_depressed./n, n_healthy./n
end
function run_sim_highses(sim, n_steps, verbose = false)
    # we keep track of the numbers
    n_depressed = Int[]
    n_healthy = Int[]

    # simulation steps
    for t in  1:n_steps
        update_agents!(sim)
        push!(n_depressed, count(p -> (p.state == depressed && p.ses == high), sim.pop))
        push!(n_healthy, count(p -> (p.state == healthy && p.ses == high), sim.pop))
        # a bit of output
        if verbose
            println(t, ", ", n_depressed[end], ", ", n_healthy[end])
        end
    end
    
    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_depressed./n, n_healthy./n
end


# angenommen, dass Möglichkeit zur Therapie von SÖS abhängt
sim = setup_sim(prev = 0.08, rem = 0.51, rem_ther = 0.45, avail_high = 1.0, avail_middle = 0.5, avail_low = 0.1, prev_parents = 0.26, prev_friends = 0.24, prev_ac = 0.12, prev_child = 0.1, prev_spouse = 0.10, N = 500, n_fam = 100, p_ac = 300/1000, p_friends = 20/1000, n_dep = 0, seed = 42)

#allgemeine Simulation
depr, heal = run_sim(sim, 500)

#je nach SÖS
deprlow, heallow = run_sim_lowses(sim, 500)
deprmiddle, healmiddle = run_sim_middleses(sim, 500)
deprhigh, healhigh = run_sim_highses(sim,500)

Plots.plot([heal, depr], labels = ["healthy" "depressed"])
#Plots.plot([heallow, deprlow], labels = ["healthy & low ses" "depressed & low ses"])
#Plots.plot([healmiddle, deprmiddle], labels = ["healthy & middle ses" "depressed & middle ses"])
#Plots.plot([healhigh, deprhigh], labels = ["healthy & high ses" "depressed & high ses"])


