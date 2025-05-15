using Pkg
Pkg.activate("Escape")
#Pkg.add(url = "https://github.com/ClapeyronThermo/Langmuir.jl")


using Plots, DelimitedFiles, Langmuir
gr() #hide
ethane_data_path = joinpath(@__DIR__, "ethane_tpl_data.csv")
ethane_data = readdlm(ethane_data_path, ',')
ethylene_data_path = joinpath(@__DIR__, "ethylene_tpl_data.csv")
P_ethane = ethane_data[:, 2]
T_ethane = ethane_data[:, 1]
l_ethane = ethane_data[:, 3]
d_ethane = isotherm_data(P_ethane, l_ethane, T_ethane)
Ts_ethane, lp_ethane = split_data_by_temperature(d_ethane)

default(fontfamily = "Computer Modern")

scatter(lp_ethane[1][2], lp_ethane[1][1], label = "T = 283.00 K (Ethane)",
xlabel = "Pressure [Pa]", ylabel = "loading [mol/kg]",
m = (4, :white, stroke(1, :slateblue2)), framestyle=:box, markershape = :square, size = (600, 350),
xformatter = :scientific,
grid = true,
minorgrid = true, minorticks = 4,
minorgridstyle = :dot,
minorgridlinewidth = 0.3,
minorgridalpha = 0.3,
ylim = (0, 8),
xlim = (0.0, maximum(P_ethane)*1.1))
scatter!(lp_ethane[3][2], lp_ethane[3][1], label = "T = 323.00 K (Ethane)", m = (4, :white, stroke(1, :lightslateblue)), markershape = :circle)


ethylene_data = readdlm(ethylene_data_path, ',')
P_ethylene = ethylene_data[:, 2]
T_ethylene = ethylene_data[:, 1]
l_ethylene = ethylene_data[:, 3]
d_ethylene = isotherm_data(P_ethylene, l_ethylene, T_ethylene)
Ts_ethylene, lp_ethylene = split_data_by_temperature(d_ethylene)

scatter!(lp_ethylene[1][2], lp_ethylene[1][1], label = "T = 283.00 K (Ethylene)", color = :mediumspringgreen, markershape = :square, m = (4, :white, stroke(1, :springgreen2)))
scatter!(lp_ethylene[3][2], lp_ethylene[3][1], label = "T = 323.00 K (Ethylene)",
markershape = :circle, m = (4, :white, stroke(1, :springgreen2)))

savefig("langs1.svg")

import Langmuir: x0_guess_fit, to_vec
#Fitting ethane
x0_ethane = to_vec(x0_guess_fit(Quadratic, d_ethane))
lb_ethane = (1e-25, 1e-25, 1e-4, -80_000.0, -80_000.0)
ub_ethane = (2000.0, 10.0, 100., -1_000.0, -1_000.0)

prob_ethane = IsothermFittingProblem(Quadratic{eltype(d_ethane)}, d_ethane, nothing, abs2, x0_ethane, lb_ethane, ub_ethane) #Bounds have to be manually tweaked. Default interval is too large
alg = DEIsothermFittingSolver(max_steps = 5000, population_size = 50,
logspace = true, verbose = true)
loss_fit_ethane, ethane_isotherm = fit(prob_ethane, alg)
println("Fitting loss for ethane is $loss_fit_ethane")
println(ethane_isotherm)


x0_ethylene = to_vec(x0_guess_fit(Quadratic, d_ethylene))
lb_ethylene = (1e-25, 1e-25, 1e-4, -80_000.0, -80_000.0)
ub_ethylene = (1e-1, 1e-1, 100., -500.0, -500.0)
prob_ethylene = IsothermFittingProblem(Quadratic{eltype(d_ethylene)}, d_ethylene, nothing, abs2, x0_ethylene, lb_ethylene, ub_ethylene)
loss_fit_ethylene, ethylene_isotherm = fit(prob_ethylene, alg)
println("Fitting loss for ethane is $loss_fit_ethylene")
println(ethylene_isotherm)


#Plotting ethane fitting
loading1_ethane = loading_at_T(ethane_isotherm, lp_ethane[1][2], Ts_ethane[1])
loading3_ethane = loading_at_T(ethane_isotherm, lp_ethane[3][2], Ts_ethane[3])
plot!(sort(lp_ethane[1][2]), sort(loading1_ethane), color = :slateblue2, label = "Quadratic - 283.0 K")
plot!(sort(lp_ethane[2][2]), sort(loading3_ethane), color = :slateblue2, label = "Quadratic - 323.0 K")

#Plotting ethylene isotherms
loading1_ethylene = loading_at_T(ethylene_isotherm, lp_ethylene[1][2], Ts_ethylene[1])
loading3_ethylene = loading_at_T(ethylene_isotherm, lp_ethylene[1][2], Ts_ethylene[3])
plot!(sort(lp_ethylene[1][2]), sort(loading1_ethylene), color = :springgreen2, label = "Quadratic - 283.0 K")
plot!(sort(lp_ethylene[1][2]), sort(loading3_ethylene), color = :springgreen2, label = "Quadratic - 323.0 K")

savefig("quadfitting.svg")


#Ethane isosteric heat
P_C₂_283K = sort(lp_ethane[1][2][2:end])
l_C₂_283K = sort(loading1_ethane[2:end])
ΔH_C₂_283K = map(p -> isosteric_heat(ethane_isotherm, p, 283.0), P_C₂_283K)

#Ethylene isosteric heat
P_C₂₌_283K = sort(lp_ethylene[1][2][2:end])
l_C₂₌_283K = sort(loading1_ethylene[2:end])
ΔH_C₂₌_283K = map(p -> isosteric_heat(ethylene_isotherm, p, 283.0), P_C₂₌_283K)

scatter(l_C₂_283K, ΔH_C₂_283K, xlabel = "Loading (mol/kg)", ylabel = "Isosteric Heat (J/mol)",
 m = (4, :white, stroke(1, :lightslateblue)), 
 markershape = :circle, label = "Ethane - 283.0 K",
 framestyle=:box, size = (600, 350),
yformatter = :scientific,
grid = true,
minorgrid = true, minorticks = 4,
minorgridstyle = :dot,
minorgridlinewidth = 0.3,
minorgridalpha = 0.3)
scatter!(l_C₂₌_283K, ΔH_C₂₌_283K, xlabel = "Loading (mol/kg)", ylabel = "-Q (J/mol)", markershape = :square, m = (3, :white, stroke(1, :springgreen2)), label = "Ethylene - 283.0 K")

savefig("isosteric.svg")


isotherms = IASTModels(ethane_isotherm, ethylene_isotherm)
@benchmark loading(isotherms, 1.0, 323., [0.5, 0.5], abstol = 1e-7, reltol = 1e-7, method = FastIAS())

y_C₂ = range(0.0, 1.00, 51) |> collect
success_y_C₂ = []
x_C₂ = []
x_C₂₌ = []
p = 1*101325.0
T = 303.0
for y_C₂_ᵢ in y_C₂
    y = [y_C₂_ᵢ, (1.0 - y_C₂_ᵢ)]
    models = [ethane_isotherm, ethylene_isotherm]
    (n_total, x, is_success) = iast(models, p, T, y, FastIAS(), maxiters = 1500, abstol = 1e-10, reltol = 1e-10)
 
    if is_success == :success
       println(is_success)
 
       push!(x_C₂, x[1])
       push!(x_C₂₌, x[2])
       push!(success_y_C₂, y_C₂_ᵢ)
 
       else
 
       nothing
 
    end
 end

 plot(success_y_C₂, x_C₂, xlabel = "x", ylabel = "y", label = "Ethane", framestyle=:box,
  size = (600, 350),
grid = true,
minorgrid = true, minorticks = 4,
minorgridstyle = :dot,
minorgridlinewidth = 0.3,
minorgridalpha = 0.3)
plot!(1.0 .- success_y_C₂, x_C₂₌, label = "Ethylene")

savefig("iast.svg")