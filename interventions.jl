Base.@kwdef mutable struct Interventions

    therapy_education::Bool = false
    therapy_education_invest:: Int64 = 50
    therapy_education_eff_para:: Float64 = 

end
function therapy_education_investment_effects()
    effect = (therapy_education_invest/100)*therapy_education_eff_para


end
function efficiency()

end
function efficacy()

end
