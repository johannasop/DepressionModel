Base.@kwdef mutable struct Parameters
  prev::Float64 = 4.310951204413029
  rem::Float64 = 0.53
  rem_ther::Float64 = 0.45
  avail_high::Float64 = 0.8
  avail_middle::Float64 = 0.6
  avail_low::Float64 = 0.3
  rate_parents::Float64= 8.037527433054109
  rate_friends::Float64 = 7.719516641505317
  rate_friends_healthy::Float64 = 1.5200877832362898
  rate_ac::Float64 = 0.5828236924050285
  rate_child::Float64 = 0.795524402363204
  rate_spouse::Float64 = 2.1805311719247995
  rate_spouse_healthy::Float64 = 4.573827698724437
  n::Int64 = 1000
  n_fam::Int64 = 280
  p_ac::Float64 = 15
  p_fr::Float64 = 4
  seed::Int64 = 0
  lambda::Float64 = 0.7782529441665396
  scaling::Float64 = 2.2183971448972186
  w_mean::Float64 = 0.6679669538759784
  #Breite der Verteilung der susceptibility des Zufalls
  b::Float64 = 5.80239
  mw_h::Float64 = 3.06181
  
  #Breite der Verteilung der resilience des Zufalls
  b_resilience::Float64 = 3.82645
  mw_h_resilience::Float64 = 3.99577
  
  #Heritabilitätsindex(?)
  h::Float64 = 0.30656
  h_resilience::Float64 = 0.42511
  h_expo::Float64 = 0.12933242876846965
  
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
  homophily_friends::Float64 = 0.2848463082973875
  homophily_spouse::Float64 = 0.2601224517376915
  homophily_ac::Float64 = 0.1601607138385214
  #Welcher Feedbackeffekt aktiviert wird
  ther_restriction :: Bool = true
  fdbck_education :: Bool = true
  fdbck_income :: Bool = true
  
  #intervention
  therapy_for_all::Bool = false
  therapy_for_lower_ses::Bool = false
  prevent_depressive_isolation::Float64 = 0
  educational_support_depressed_kids::Float64 = 0
  job_support_depressed_pop::Float64 = 0
  end
  