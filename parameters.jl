Base.@kwdef mutable struct Parameters

    prev::Float64 = 9.4749
    rem::Float64 = 0.53
    rem_ther::Float64 = 0.45
    avail_high::Float64 = 0.2
    avail_middle::Float64 = 0.1
    avail_low::Float64 = 0.0
    rate_parents::Float64=  9.26244
    rate_friends::Float64 = 2.1319
    rate_ac::Float64 = 4.911
    rate_child::Float64 = 6.519
    rate_spouse::Float64 = 0.305
    n::Int64 = 1000
    n_fam::Int64 = 280
    p_ac::Float64 = 15
    p_fr::Float64 = 4
    seed::Int64 = 0

    lambda::Float64 = 0.00654
    scaling::Float64 = 3.245
    #Breite der Verteilung der susceptibility des Zufalls
    w_mean::Float64 = 0.0399
    b::Float64 = 6.800
    mw_h::Float64 = -4.461

    #Heritabilitätsindex(?)
    h::Float64 = 0.01191
    
    #Wahrscheinlichkeiten für unterschiedliche Anzahl von Kindern
    p_none::Float64 = 0.18
    p_kids::Vector{Float64} = [0.44, 0.85, 0.98]
    findingpartner::Float64 = 0.40

    #Wahrscheinlichkeiten für Beziehungskrams: hier nochmal nach besserer Quelle suchen
    #durations beinhaltet die häufigsten Trennungsjahre, also wird zufällig eines dieser Jahre ausgewählt und dann aus einer Poisson-Verteilung die erwartete Beziehungsdauer bestimmt
    partnersamecircle::Float64 = 0.7
    durations::Vector{Int64} = [3, 7, 15]

    #Nummer neuer enger Freunde und weniger enger Freunde pro Jahr
    new_ac_year::Int64 = 1
    p_new_friend_year::Float64 = 0.1
    friendloss::Float64 = 0.10
    acloss::Float64 = 0.30

    #Einkommensverteilung sd 
    sd_income::Float64 = 7.5

    #Wahrscheinlichkeit wegen Depression Bildungsweg zu verlassen: hier noch nach korrekten Zahlen schauen
    depressiondropout::Float64 = 0.05
    depression_jobloss::Float64 = 0.05
    better_edu_thanparents::Float64 = 0.02

    #twins
    prob_twins::Float64 = 0.0137

    #homophily
    homophily_friends::Float64 = 0.2751
    homophily_spouse::Float64 = 0.6505
    homophily_ac::Float64 = 0.9278

    #Welcher Feedbackeffekt aktiviert wird
    ther_restriction :: Bool = true
    fdbck_education :: Bool = false
    fdbck_income :: Bool = false

end