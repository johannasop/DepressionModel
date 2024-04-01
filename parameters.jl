Base.@kwdef mutable struct Parameters

    prev::Float64 = 0.655886
    rem::Float64 = 0.53
    rem_ther::Float64 = 0.45
    avail_high::Float64 = 0.2
    avail_middle::Float64 = 0.1
    avail_low::Float64 = 0.0
    rate_parents::Float64=  7.7504
    rate_friends::Float64 = 2.1205
    rate_ac::Float64 = 2.7277
    rate_child::Float64 = 7.2238
    rate_spouse::Float64 = 7.5871
    n::Int64 = 2000
    n_fam::Int64 = 560
    p_ac::Float64 = 15
    p_fr::Float64 = 4
    seed::Int64 = 0

    lambda::Float64 = 0.0224
    scaling::Float64 = 2.3134
    #Breite der Verteilung der susceptibility des Zufalls
    w_mean::Float64 = 0.036559
    b::Float64 = 2.8067
    mw_h::Float64 = -5.13995

    #Heritabilitätsindex(?)
    h::Float64 = 0.14039
    
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
    homophily_friends::Float64 = 0.00874
    homophily_spouse::Float64 = 0.32855
    homophily_ac::Float64 = 0.1567

    #Welcher Feedbackeffekt aktiviert wird
    ther_restriction :: Bool = true
    fdbck_education :: Bool = false
    fdbck_income :: Bool = false

end