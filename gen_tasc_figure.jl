#!/usr/bin/env julia
# Run from blog_book root: julia --project=~/projects/software/TASC.jl gen_tasc_figure.jl

using Pkg
Pkg.activate(joinpath(homedir(), "projects", "software", "TASC.jl"))

using CSV, DataFrames, Statistics
using SynthDiD
using TASC
using CairoMakie

# ── Load and pivot Prop 99 data ──────────────────────────────────────────────
df = CSV.read("california_prop99.csv", DataFrame)

states = sort(unique(df.State))
years  = sort(unique(df.Year))
N = length(states); T = length(years)

Y_wide = zeros(N, T)
treated_vec = zeros(Bool, N)
for row in eachrow(df)
    i = findfirst(==(row.State), states)
    t = findfirst(==(row.Year), years)
    Y_wide[i, t] = row.PacksPerCapita
    treated_vec[i] |= (row.treated == 1)
end

ctrl_idx = findall(.!treated_vec)
trt_idx  = findall(treated_vec)
Y        = Y_wide[vcat(ctrl_idx, trt_idx), :]
N0       = length(ctrl_idx)
T0       = findfirst(==(1989), years) - 1   # 19 pre-treatment years
california = vec(Y[N0 + 1, :])

# Helper: build counterfactual path from donor weights + level intercept
# (so pre-period matches California's mean when intercept=true)
function cfact_path(Y, N0, T0, omega; intercept=true)
    path = vec(omega' * Y[1:N0, :])
    if intercept
        ca_pre_mean  = mean(Y[N0 + 1, 1:T0])
        ctrl_pre_mean = mean(path[1:T0])
        path .+= (ca_pre_mean - ctrl_pre_mean)
    end
    return path
end

# ── Four estimators ───────────────────────────────────────────────────────────
tau_did  = did_estimate(Y, N0, T0)
tau_sdid = synthdid_estimate(Y, N0, T0)
tau_sc   = sc_estimate(Y, N0, T0)

cfact_did  = cfact_path(Y, N0, T0, tau_did.weights.omega;  intercept=true)
cfact_sdid = cfact_path(Y, N0, T0, tau_sdid.weights.omega; intercept=true)
cfact_sc   = cfact_path(Y, N0, T0, tau_sc.weights.omega;   intercept=false)  # SC: no intercept

# TASC: treated row first
Y_tasc = vcat(Y[(N0+1):end, :], Y[1:N0, :])
model  = fit_tasc(Y_tasc; d=2, T0=T0, n_em=200, tol=1e-3)
pred   = predict_counterfactual(model, Y_tasc)
cfact_tasc = vec(pred.target)
tasc_se    = sqrt.(max.(vec(pred.variance), 0.0))
tasc_lower = cfact_tasc .- 1.96 .* tasc_se
tasc_upper = cfact_tasc .+ 1.96 .* tasc_se

# ── ATTs ─────────────────────────────────────────────────────────────────────
att(ca, cf, T0) = mean(ca[(T0+1):end] .- cf[(T0+1):end])
println("DiD  ATT: $(round(att(california, cfact_did,  T0), digits=2))")
println("SDiD ATT: $(round(att(california, cfact_sdid, T0), digits=2))")
println("SC   ATT: $(round(att(california, cfact_sc,   T0), digits=2))")
println("TASC ATT: $(round(att(california, cfact_tasc, T0), digits=2))")

# ── Figure ───────────────────────────────────────────────────────────────────
fig = Figure(size = (800, 430), fontsize = 13)
ax  = Axis(fig[1, 1],
    xlabel = "Year",
    ylabel = "Packs per capita",
    title  = "California Prop 99: counterfactual paths by estimator",
)

band!(ax, years, tasc_lower, tasc_upper;
    color = (:seagreen, 0.18), label = "TASC 95% interval")
lines!(ax, years, california;
    color = :black, linewidth = 3, label = "California (observed)")
lines!(ax, years, cfact_did;
    color = :tomato, linewidth = 2, linestyle = :dash, label = "DiD")
lines!(ax, years, cfact_sdid;
    color = :darkorange, linewidth = 2, linestyle = :dash, label = "SDiD")
lines!(ax, years, cfact_sc;
    color = :steelblue, linewidth = 2, label = "SC")
lines!(ax, years, cfact_tasc;
    color = :seagreen, linewidth = 2, label = "TASC")
vlines!(ax, [years[T0] + 0.5]; color = :gray40, linestyle = :dash, linewidth = 1)
text!(ax, years[T0] + 0.7, 220; text = "Prop 99\n(1989)", color = :gray50, fontsize = 11)

axislegend(ax; position = :lb, framevisible = false)
save("tasc-prop99.svg", fig)
println("Saved tasc-prop99.svg")
