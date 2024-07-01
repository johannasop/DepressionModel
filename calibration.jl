
Base.@kwdef struct EmpiricalParams
    prev_12month::Float64 = 0.075
    prev_15to65::Float64 = 0.25

    h::Float64 = 0.37
    c::Float64 = 0.0
    e::Float64 = 0.63

    increased_parents_30::Float64 = 0.30 #Achtung: Ergebnis aus Funktion muss dann in Kalibierung durch 10 geteilt werden
    increased_friends_4::Float64 = 4.59
    increased_ac_4::Float64 = 2.18
    increased_spouse_4::Float64 = 1.5
    
    dep_episode_one_more::Float64 = 0.50
    dep_episode_two_more::Float64 = 0.75
    dep_episode_three_more::Float64 = 0.90
end
