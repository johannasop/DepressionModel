
function feedbackeffect_academics(sim)

    for person in sim.pop 
        ses_school(person)
        family_school(person)
    end

end

function ses_school(person)
    if person.ses == high
        person.acachievement = rand(Normal(1.0, 0.1))
    
    elseif person.ses == middle 
        person.acachievement = rand(Normal(0.5, 0.1))

    elseif person.ses == low
        person.acachievement = rand(Normal(0.0, 0.1))
    end

    if person.acachievement > 1.0 
        person.acachievement = 1.0

    elseif person.acachievement < 0.0
        person.acachievement = 0.0
    end
end

function family_school(person)
    mean = 0
    if length(person.parents) != 0 
        for parent in person.parents
            mean = mean + parent.acachievement
        end
    end
    mean = mean/length(person.parents)
    person.acachievement = 0.5*(mean) + 0.5*(person.acachievement)
end

function depression_achievement(person)
    if person.state == depressed
        person.acachievement = person.acachievement - rand(Normal(-0.1, 0.1))
    end
end

function achievementtoses(sim)
    for person in sim.pop
        if person.acachievement <= 0.33 && person.ses != low 
            person.ses = low
            println("down ", person.state)
        elseif person.acachievement <= 0.66 && person.ses == low
            person.ses = middle
            println("up ", person.state)
        elseif person.acachievement <= 0.66 && person.ses == high
            person.ses = middle 
            println("down ", person.state)
        elseif person.acachievement <= 1.0 && person.ses!= high 
            person.ses = high
            prinln("up ", person.state)
        else 
            println("no changed ses")
        end

    end
end
