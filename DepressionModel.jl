using Random
using Plots
using DifferentialEquations
using Distributions
using CSV
using DataFrames

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

end

# how we construct a person object
SimplePerson() = SimplePerson([], [], [], [], [], 0, healthy, middle, 0)   # default Person is susceptible and has no contacts
SimplePerson(state) = SimplePerson([], [], [], [], [], 0, state, middle, 0)  # default Person has no contacts


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

    #Spontanremmisionen 
    if person.state == depressed && rand() < sim.rem
        person.state = healthy
    end

    therapy!(person, sim)
end

function therapy!(person, sim)

    #Wahrscheinlichkeit sich in Therapie zu begeben in Abhängigkeit des SÖS
    if person.ses == high 
        person.prob_ther = sim.avail_high
    end
    if person.ses == middle 
        person.prob_ther = sim.avail_middle
    end
    if person.ses == low 
        person.prob_ther = sim.avail_low
    end
    
    #Annahme, dass Therapiemotivation mit weniger Erfolg sinkt
    if rand() < person.prob_ther && rand() < sim.rem_ther
        person.state = healthy
    else
        person.prob_ther = person.prob_ther - 0.1
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
     end


    #erstelle Familien mit Partnern
    for i=1:n_fam

        x = rand(1:length(men))
        y = rand(1:length(women))
        man = men[x]
        woman = women[y]

        #gleicher SÖS
        woman.ses = man.ses

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
        x = rand(1:(n_fam*2))   

        #gleicher SÖS wie Eltern
        kids[i].ses = pop[x].ses 

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
            if rand() < p_ac && !(pop[i] in pop[j].spouse) && !(pop[i] in pop[j].children) && !(pop[i] in pop[j].parents)
                push!(pop[i].ac, pop[j])
                push!(pop[j].ac, pop[i])
            elseif rand() < p_fr && !(pop[i] in pop[j].spouse) && !(pop[i] in pop[j].children) && !(pop[i] in pop[j].parents)
                push!(pop[i].friends, pop[j])
                push!(pop[j].friends, pop[i])
            end
           
        end
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
            
    sim
end

function run_sim(sim, n_steps, verbose = false)
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
        update_agents!(sim)
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
    end
    
    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_depressed./n, n_healthy./n , n_depressed_high./n, n_healthy_high./n, n_depressed_middle./n, n_healthy_middle./n,  n_depressed_low./n, n_healthy_low./n
end




# angenommen, dass Möglichkeit zur Therapie von SÖS abhängt
sim = setup_sim(prev = 0.08, rem = 0.51, rem_ther = 0.45, avail_high = 0.7, avail_middle = 0.4, avail_low = 0.1, prev_parents = 0.26, prev_friends = 0.24, prev_ac = 0.12, prev_child = 0.1, prev_spouse = 0.10, N = 500, n_fam = 100, p_ac = 300/1000, p_friends = 20/1000, n_dep = 0, seed = 42)


depr, heal, deprhigh, healhigh, deprmiddle, healmiddle, deprlow, heallow = run_sim(sim, 50)


Plots.plot([heal, depr, healhigh, deprhigh, healmiddle, deprmiddle, heallow, deprlow], labels = ["healthy" "depressed" "healthy high ses" "depressed high ses" "healthy middle ses" "depressed middle ses" "healthy low ses" "depressed low ses"])



