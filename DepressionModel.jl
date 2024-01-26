using Random
using Plots
using DifferentialEquations
using Distributions
using CSV
using DataFrames
using MiniObserve
using Statistics
using AlgebraOfGraphics
using CairoMakie
using LIBSVM
using Makie
using Graphs
using GraphPlot
using NetworkLayout
using Colors
using Karnak

include("parameters.jl") 


# all possible states a person can be in
@enum State healthy depressed
# this is our agent type
mutable struct SimplePerson
    alive::Bool
    # contacts
    friends :: Vector{SimplePerson}
    parents :: Vector{SimplePerson}
    children :: Vector{SimplePerson}
    # warum ein Vector?
    spouse :: Vector{SimplePerson}
    ac :: Vector{SimplePerson}
    twin :: Vector{SimplePerson}

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

    #relevant social circle for social dynamics; already known people are excluded
    rel_socialcircle::Vector{SimplePerson}

    #length of current depressive episode
    length_dep_episode::Int64

    #number of depressive episodes total and at age 65: important for calibration
    n_dep_episode::Int64
    n_dep_episode_65::Int64

end


# how we construct a person object
SimplePerson() = SimplePerson(true,[], [], [], [], [], [], 0, healthy, 0, 0, 0, 0, 0, 0, 0, [], 0, 0, 0)   # default Person is susceptible and has no contacts
SimplePerson(state) = SimplePerson(true,[], [], [], [], [], [], 0, state, 0, 0, 0, 0, 0, 0, 0, [], 0, 0, 0)  # default Person has no contacts


# this is a parametric type
# we can specify which type AGENT is going to be replaced with
# when constructing our Simulation
mutable struct Simulation{AGENT}
    
    pop :: Vector{AGENT}

    pop_singles :: Vector{AGENT}
    pop_potentialparents :: Vector{AGENT}

    pop_identical_twins :: Vector{AGENT}
    pop_fraternal_twins :: Vector{AGENT}

    pop_depressed :: Vector{AGENT}
    pop_non_depressed :: Vector{AGENT}
    pop_currently_depressed :: Vector{AGENT}

    time::Int64
end

function update!(person, sim, para)
 
    person_died = population_update!(person, sim, para)

    #Person sollte dann auch niemanden mehr anstecken können
    if person_died
        return
    end

    rate = 0

    if (findfirst(p-> p.state == depressed, person.parents) != nothing)
        rate += para.rate_parents
    end

    if (findfirst(p-> p.state == depressed, person.children) != nothing) 
        rate += para.rate_child
    end

    percentage = count(p -> p.state == depressed, person.friends)/length(person.friends)
    rate += para.rate_friends * percentage

    percentage = count(p -> p.state == depressed, person.ac)/length(person.ac)
    rate += para.rate_ac * percentage

    if length(person.spouse) > 0 && person.spouse[1].state == depressed 
        rate += para.rate_spouse
    end
    
    if rate == 0
        rate += para.prev
    end

    person.risk = ratetoprob(rate * person.susceptibility)
    if person.age >= 15 && rand() < person.risk
        person.state = depressed
        push!(sim.pop_currently_depressed, person)
    end
  
    #Spontanremmisionen 
    if person.state == depressed && rand() < ratetoprob(para.rem)
        person.state = healthy
        person.n_dep_episode += 1
        person.length_dep_episode = 0

        setprobther!(person, para)
    elseif person.state == depressed
        person.length_dep_episode += 1
    end

    if person.state == depressed
        therapy!(person, para)
    end
end

function population_update!(person, sim, para)

    person.age += 1

    #Menschen sterben lassen: hier hab ichs noch nicht besser hingekriegt
    if person.age > 80
        if person.n_dep_episode == 0
            push!(sim.pop_non_depressed, person)
        else
            push!(sim.pop_depressed, person)
        end
        return death!(person, sim)
    end
    if person.age == 65
        person.n_dep_episode_65 = person.n_dep_episode
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

    #Dynamik im sozialen Umfeld!
    social_dynamic!(person, para, sim)

    #SÖS: ergibt sich aus SÖS der Eltern, bisschen Zufall aber enthalten, da Intervall des Incomes bei Berechnung des incomes aus Bildungsstand heraus bisschen überlappt für jeden Bildungsstand
    #hier wird quasi erwarteter Bildungsstand berechnet

    #es wird vom Einkommen der wohlverdienenderen Person ausgegangen
    if person.age == 18
        set_ses!(person,para)
    end

    #Wenn Personen in diesen Altersklassen Depressionen entwickeln, kann es sein, dass sie den "erwarteten" Bildungsstand nicht erreichen; dieser Feedbackeffekt lässt sich ausschalten

    if para.fdbck_education
        if person.age <= 18 && person.age <= 25 && person.state == depressed && person.education > 1
            if rand() < para.depressiondropout
                person.education -= 1
            end
        end
    end

    #Wahrscheinlichkeit sich in Therapie zu begeben in Abhängigkeit des SÖS
    if person.age == 18
        setprobther!(person, para) 
    end

    #Einstieg ins Berufsleben
    if person.age == 25
        calculateincome!(person, para)
    end

    #Falls Depressionen im Erwachsenenalter auftreten, kann Job verloren gehen und dann verschlechtert sich finanzielle Situation
    #Feedbackeffekt Einkommensverlust bei Depressionen lässt sich ausschalten
    if para.fdbck_income
        if person.age > 25 && person.state == depressed && person.income >= 10
            if rand() < para.depression_jobloss
                person.income -= 10
            end
        end
    end

    return false
 end

 function add_eachother!(person, plist, other, olist)

    push!(plist, other)
    push!(olist, person)

 end

 function everdepressed(person)

    if person.n_dep_episode == 0
        return false
    else
        return true
    end

 end

 function set_ses!(person,para)
    parentalincome = max(person.parents[1].income, person.parents[2].income)

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

function newkid!(sim, para)

    if isempty(sim.pop_potentialparents)
        return
    end

    newkid = SimplePerson()

    #Eltern für neues Kind finden
    parent = rand(sim.pop_potentialparents)
    parent2 = parent.spouse[1]

    #SES und susceptibility: gleicher SES wie Eltern aber bisschen andere susceptibility
    newkid.susceptibility =  (para.h * ((parent.susceptibility + parent2.susceptibility)/2) + ((1-para.h) * limit(0, rand(Normal(1,para.b)), 50))) 

    add_eachother!(newkid, newkid.parents, parent, parent.children)
    add_eachother!(newkid, newkid.parents, parent2, parent2.children)
    
    #werden Eltern gelöscht oder bleiben auf der Liste potentieller Eltern? Außerdem können sie mehr als drei Kinder kriegen
    p = para.p_kids[min(3, length(parent.children))]

    if rand() < p
        del_unsorted!(parent, sim.pop_potentialparents)
        del_unsorted!(parent2, sim.pop_potentialparents)
    end

    #neue Menschen brauchen Freunde und Bekannte, das dürfen aber nicht sie selber sein 
    findsocial!(newkid, sim.pop, para)
        
    #Ist das neue Kind ein Zwilling?
    if rand() < para.prob_twins
        newtwin = SimplePerson()

        #add twin to all social connections
        socialcircle_twin!(newkid, newtwin)

        if rand() < (1/3)
            newtwin.susceptibility = newkid.susceptibility
            push!(sim.pop_identical_twins, newtwin)
        else
            newtwin.susceptibility = (para.h * ((parent.susceptibility + parent2.susceptibility)/2) + ((1-para.h) * limit(0, rand(Normal(1,para.b)), 50))) 
            push!(sim.pop_fraternal_twins, newtwin)
        end

        add_eachother!(newkid, newkid.twin, newtwin, newtwin.twin)

        push!(sim.pop, newtwin)
    end

    push!(sim.pop, newkid)

end


function death!(person, sim)
    person.alive=false

    #Sterbeprozess
    #Partner der sterbenden Person: falls vorhanden wird wieder single und von Liste potentieller Eltern entfernt, gemeinsam mit sterbender Person
    if length(person.spouse)> 0
        spouse = person.spouse[1]
        push!(sim.pop_singles, spouse)
        
        del_unsorted!(person.spouse[1], sim.pop_potentialparents)
        del_unsorted!(person, sim.pop_potentialparents)

        pop!(spouse.spouse)
    else
        del_unsorted!(person, sim.pop_singles)
    end

    #Person muss noch von Listen aller ihr bekannten und befreundeten Personen gelöscht werden, denn hier kann kein Kontakt mehr bestehen
    for friend in person.friends        
        del_unsorted!(person, friend.friends)
    end

    for ac in person.ac
        del_unsorted!(person, ac.ac)     
    end
    
    #Person muss außerdem aus dem sc von jeder Person gelöscht werden
    for other in sim.pop        
        del_unsorted!(person, other.rel_socialcircle)
    end

    #Mensch aus Population entfernen
    del_unsorted!(person, sim.pop)
    return true
end


function newpartner!(person, sim, para)

    #solange noch kein Partner gefunden wurde, durchlaufen lassen, um aber festhängen zu vermeiden, maximal 100 mal
    counter = 0

    while length(person.spouse) == 0 && counter <= 100
        #Wahrscheinlichkeit aus dem gleichen Umfeld zu kommen, wird dann nochmal hälftig auf Freundeskreis und hälftig auf Bekanntenkreis aufgeteilt

        if rand() < para.partnersamecircle
            if rand() < 0.5 && length(person.friends)>0
                potpartner = rand(person.friends)
            elseif length(person.ac)>0
                potpartner = rand(person.ac)
            else
                potpartner = rand(sim.pop_singles)
            end
        else
            x = rand(1:length(sim.pop_singles))
            potpartner = sim.pop_singles[x]
        end

        #Bedingungen: Partner muss single sein, der Altersunterschied darf nicht zu groß sein und der SES muss gleich sein, außerdem dürfen es nicht sie selber sein
        if length(potpartner.spouse) == 0 && (abs(potpartner.age - person.age) <= 5+(person.age*0.1)) && potpartner.education == person.education && potpartner.age >= 18 && potpartner != person && !(potpartner in person.parents) && !(potpartner in person.children) && (everdepressed(person) == everdepressed(potpartner))
            #für beide die Beziehungsdauer bestimmen
            person.rellength = rand(Poisson(para.durations[rand(1:length(para.durations))]))
            potpartner.rellength = person.rellength

            add_eachother!(person, person.spouse, potpartner, potpartner.spouse)

            add_to_sc!(person, potpartner)
            add_to_sc!(potpartner, person)

            del_unsorted!(potpartner, person.rel_socialcircle)
            del_unsorted!(person, potpartner.rel_socialcircle)

            del_unsorted!(person, sim.pop_singles)
            del_unsorted!(potpartner, sim.pop_singles)

            #sind nun keine Bekannten oder Freunde mehr
            del_unsorted!(potpartner, person.friends)
            del_unsorted!(person, potpartner.friends) 
            del_unsorted!(potpartner, person.ac)
            del_unsorted!(person, potpartner.ac)
        
            #Personen landen auf der Liste bei bestimmter Wahrscheinlichkeit: ab 55 Jahren können sie keine Kinder mehr bekommen
            if rand() > para.p_none && person.age < 50 && potpartner.age < 50
                push!(sim.pop_potentialparents, person)
                push!(sim.pop_potentialparents, potpartner)
            end
        end
        counter += 1
    end
end

function splitup!(person, sim)
    spouse = person.spouse[1]
    #Beziehungsparameter wieder auf 0 setzen
    person.currdur = 0
    spouse.currdur = 0

    person.rellength = 0
    spouse.rellength = 0


    #wieder auf Listen der Singles setzen und von Liste potenzieller Eltern entfernen
    push!(sim.pop_singles, person)
    push!(sim.pop_singles, spouse)

    del_unsorted!(person, sim.pop_potentialparents)
    del_unsorted!(spouse, sim.pop_potentialparents)

    #Trennung einleiten
    pop!(spouse.spouse)
    pop!(person.spouse)

end


is_stranger(person, other) = other != person && !(other in person.parents) && !(other in person.spouse) && !(other in person.children) && !(other in person.friends) && !(other in person.ac)


function findsocial!(person, pop, para)

    number_ac = rand(Poisson(para.p_ac))
    number_fr = rand(Poisson(para.p_fr))

    while length(person.friends) < number_fr
        pos_fr = rand(pop)
        if is_stranger(person, pos_fr) && (5 + (person.age*0.25) > abs(person.age-pos_fr.age)) 
            add_eachother!(person, person.friends, pos_fr, pos_fr.friends)

            add_to_sc!(person, pos_fr)
            add_to_sc!(pos_fr, person)

            del_unsorted!(pos_fr, person.rel_socialcircle)
            del_unsorted!(person, pos_fr.rel_socialcircle)
        end
    end

    while length(person.ac) < number_ac
        #sollte es keine potenziellen Bekannten mehr im Umkreis geben, oder die Person keine Freunde haben, werden einfach Personen aus der Population ausgewählt
        if length(person.friends) == 0 || length(person.rel_socialcircle) == 0
            pos_ac = rand(pop)
            if is_stranger(person, pos_ac) 
                add_eachother!(person, person.ac, pos_ac, pos_ac.ac)

                del_unsorted!(pos_ac, person.rel_socialcircle)
                del_unsorted!(person, pos_ac.rel_socialcircle)
            end
        else
            #folgende Lösung würde die Freunde von Freunden zu Bekannten machen und so noch mehr ein tatsächliches Netzwerk erzeugen
            pos_ac = rand(person.rel_socialcircle)
            add_eachother!(person, person.ac, pos_ac, pos_ac.ac)
            del_unsorted!(pos_ac, person.rel_socialcircle)
            del_unsorted!(person, pos_ac.rel_socialcircle)
        end
    end            
end

function socialcircle_twin!(newkid, newtwin)

    for parent in newkid.parents
        add_eachother!(newtwin, newtwin.parents, parent, parent.children)
    end
    for friend in newkid.friends
        add_eachother!(newtwin, newtwin.friends, friend, friend.friends)
    end
    for ac in newkid.ac
        add_eachother!(newtwin, newtwin.ac, ac, ac.ac)
    end
    for person in newkid.rel_socialcircle
        push!(newtwin.rel_socialcircle, person)
    end

end

function findsocial_old!(person, pop, para)
    number_ac = rand(Poisson(para.p_ac))
    number_fr = rand(Poisson(para.p_fr))

    while length(person.friends) < number_fr
        pos_fr = pop[rand(1:length(pop))] 
        if pos_fr != person  && !(pos_fr in person.parents) && !(pos_fr in person.spouse) && !(pos_fr in person.children) && !(pos_fr in person.friends)
            add_eachother!(person, person.friends, pos_fr, pos_fr.friends)
        end
    end
    while length(person.ac) < number_ac
        pos_ac = pop[rand(1:length(pop))]
        if pos_ac != person && !(pos_ac in person.parents) && !(pos_ac in person.spouse) && !(pos_ac in person.children) && !(pos_ac in person.ac) && !(pos_ac in person.friends)
            add_eachother!(person, person.ac, pos_ac, pos_ac.ac)
        end
    end
end

function social_dynamic!(person, para, sim)

    #jährlich neue Bekannte: diese sollen aus dem ähnlichen sozialen Umfeld stammen und den gleichen mental state haben
    for i=1:rand(Poisson(para.new_ac_year))
        if length(person.ac) == 0 || length(person.rel_socialcircle) == 0
            break
        end
        old_ac = rand(person.ac)
        del_unsorted!(old_ac, person.ac)
        del_unsorted!(person, old_ac.ac)

        #new ac is picked dependend on depression State
        if any(p->everdepressed(p) == everdepressed(person), person.rel_socialcircle) 
            while true
                pos_ac = rand(person.rel_socialcircle)

                @assert is_stranger(person, pos_ac)

                if everdepressed(person) == everdepressed(pos_ac) 
                    add_eachother!(person, person.ac, pos_ac, pos_ac.ac)
                    del_unsorted!(pos_ac, person.rel_socialcircle)
                    del_unsorted!(person, pos_ac.rel_socialcircle)
                    break
                end
            end

        else
            while true

                pos_ac = rand(sim.pop)

                if is_stranger(person, pos_ac) 
                    add_eachother!(person, person.ac, pos_ac, pos_ac.ac)
                    del_unsorted!(pos_ac, person.rel_socialcircle)
                    del_unsorted!(person, pos_ac.rel_socialcircle)
                    break
                end
            end
        end
    end
    
    if length(person.friends)>0 && length(person.rel_socialcircle) > 0 &&
		rand() < para.p_new_friend_year

        old_friend = rand(person.friends)
        del_unsorted!(old_friend, person.friends)
        del_unsorted!(person, old_friend.friends)

        #new friend is picked dependend on depression State
        if any(p-> everdepressed(p) == everdepressed(person), person.rel_socialcircle) 
            while true
                pos_fr = rand(person.rel_socialcircle)

                if everdepressed(pos_fr) == everdepressed(person)
                    add_eachother!(person, person.friends, pos_fr, pos_fr.friends)
                    add_to_sc!(person, pos_fr)
                    add_to_sc!(pos_fr, person)
                    del_unsorted!(pos_fr, person.rel_socialcircle)
                    del_unsorted!(person, pos_fr.rel_socialcircle)
                    break
                end
            end
        else
            while true
                pos_fr = rand(sim.pop)

                if is_stranger(person, pos_fr) && 5+(person.age*0.25)>abs(person.age-pos_fr.age) 
                    add_eachother!(person, person.friends, pos_fr, pos_fr.friends)
                    add_to_sc!(person, pos_fr)
                    add_to_sc!(pos_fr, person)
                    del_unsorted!(pos_fr, person.rel_socialcircle)
                    del_unsorted!(person, pos_fr.rel_socialcircle)
                    break
                end 
            
            end
        end
        end

    #mit gewisser Wahrscheinlichkeit verlieren depressive Personen darüber hinaus auch Freunde und Bekannte nach gewisser Zeit; hier ab zweitem Jahr der Depression 

    if length(person.friends) > 0 && person.state == depressed && rand() < para.friendloss && person.length_dep_episode > 1
        fr = rand(person.friends)

        del_unsorted!(fr, person.friends)
        del_unsorted!(person, fr.friends)

    elseif length(person.ac) > 0 && person.state == depressed && rand() < para.acloss && person.length_dep_episode > 1
        ac = rand(person.ac)

        del_unsorted!(person, ac.ac)
        del_unsorted!(ac, person.ac)
    end

end


function add_to_sc!(person, newperson)

    for friend in newperson.friends
        if is_stranger(person,friend) && !(friend in person.rel_socialcircle)
            push!(person.rel_socialcircle, friend)
        end
    end

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


function setprobther!(person, para)

    #Wahrscheinlichkeit sich in Therapie zu begeben in Abhängigkeit des SÖS
    if para.ther_restriction
        if person.education == 4
            person.prob_ther = para.avail_high
        elseif person.education >= 2
            person.prob_ther = para.avail_middle
        else
            person.prob_ther = para.avail_low
        end
    else
        person.prob_ther = 1
    end

end


function therapy!(person, para)

    #Annahme, dass Therapiemotivation mit weniger Erfolg sinkt
    if rand() < person.prob_ther 
        if rand() < ratetoprob(para.rem_ther)
            person.state = healthy
            person.n_dep_episode += 1
            person.length_dep_episode = 0
        elseif (person.prob_ther - 0.1) > 0
            person.prob_ther = person.prob_ther - 0.1
        end
    end

end

function ratetoprob(r)
    return 1- exp(-r)
end

function del_unsorted!(person, list)

    idx = findfirst(x->x==person, list)
	if idx == nothing
		return false
	end
    list[idx] = last(list)
    pop!(list)
	true
end

function update_agents!(sim, para)
    # we need to change the order, otherwise agents at the beginning of the 
    # pop array will behave differently from those further in the back
    sim.pop = shuffle(sim.pop)

    i = length(sim.pop)
    
    while i > 0
        update!(sim.pop[i], sim, para)
        i -= 1
    end

    while length(sim.pop) < para.n 
        newkid!(sim, para)
    end

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

