

Base.@kwdef mutable struct Parameters

    prev::Float64 = 0.12
    rem::Float64 = 0.51
    rem_ther::Float64 = 0.45
    avail_high::Float64 = 0.5
    avail_middle::Float64 = 0.2
    avail_low::Float64 = 0.1
    rate_parents::Float64 = 0.35
    rate_friends::Float64 = 0.40
    rate_ac::Float64 = 0.16
    rate_child::Float64 = 0.35
    rate_spouse::Float64 = 0.30
    n::Int64 = 1000
    n_fam::Int64 = 300
    p_ac::Float64 = 50
    p_fr::Float64 = 15
    seed::Int64 = 42

    #Breite der Verteilung der susceptibility
    b::Float64 = 0.1

    #Heritabilitätsindex(?)
    h::Float64 = 0.0

    #Wahrscheinlichkeiten für unterschiedliche Anzahl von Kindern
    p_none::Float64 = 0.18
    p_kids::Vector{Float64} = [0.44, 0.85, 0.98]
    findingpartner::Float64 = 0.40

    #Wahrscheinlichkeiten für Beziehungskrams: hier nochmal nach besserer Quelle suchen
    #durations beinhaltet die häufigsten Trennungsjahre, also wird zufällig eines dieser Jahre ausgewählt und dann aus einer Poisson-Verteilung die erwartete Beziehungsdauer bestimmt
    partnersamecircle::Float64 = 0.7
    durations::Vector{Int64} = [3, 7, 15]

    #Wahrscheinlichkeit wegen Depression Bildungsweg zu verlassen: hier noch nach korrekten Zahlen schauen
    depressiondropout::Float64 = 0.1
    depression_jobloss::Float64 = 0.05

end