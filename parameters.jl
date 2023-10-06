

Base.@kwdef mutable struct Parameters

    prev::Float64 = 1.0
    rem::Float64 = 0.51
    rem_ther::Float64 = 0.45
    avail_high::Float64 = 0.5
    avail_middle::Float64 = 0.2
    avail_low::Float64 = 0.1
    rate_parents::Float64 = 0.0
    rate_friends::Float64 = 0.159
    rate_ac::Float64 = 0.088
    rate_child::Float64 = 0.363
    rate_spouse::Float64 = 0.317
    n::Int64 = 1000
    n_fam::Int64 = 300
    p_ac::Float64 = 50
    p_fr::Float64 = 15
    seed::Int64 = 25

    #Breite der Verteilung der susceptibility
    b::Float64 = 0.1

    #Heritabilitätsindex(?)
    h::Float64 = 0.0

    #Wahrscheinlichkeiten für unterschiedliche Anzahl von Kindern
    p_none::Float64 = 0.42
    p_kids::Vector{Float64} = [0.45, 0.86, 1]
    findingpartner::Float64 = 0.007
    partnersamecircle::Float64 = 0.5

end