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

# Put controls first (SynthDiD convention)
ctrl_idx = findall(.!treated_vec)
trt_idx  = findall(treated_vec)
order    = vcat(ctrl_idx, trt_idx)
Y        = Y_wide[order, :]
N0       = length(ctrl_idx)
T0       = findfirst(==(1989), years) - 1   # 1970–1988 pre-period

# ── Static SC ────────────────────────────────────────────────────────────────
tau_sc = sc_estimate(Y, N0, T0)
sc_cfact = vec(tau_sc.weights.omega' * Y[1:N0, :])

# ── TASC ─────────────────────────────────────────────────────────────────────
Y_tasc = vcat(Y[(N0+1):end, :], Y[1:N0, :])   # treated row first
model  = fit_tasc(Y_tasc; d=2, T0=T0, n_em=500, tol=1e-3)
pred   = predict_counterfactual(model, Y_tasc)

california   = vec(Y[(N0+1), :])
tasc_cfact   = vec(pred.target)
tasc_se      = sqrt.(max.(vec(pred.variance), 0.0))
tasc_lower   = tasc_cfact .- 1.96 .* tasc_se
tasc_upper   = tasc_cfact .+ 1.96 .* tasc_se

# ── Figure ───────────────────────────────────────────────────────────────────
fig = Figure(size = (780, 400), fontsize = 13)
ax  = Axis(fig[1, 1],
    xlabel = "Year",
    ylabel = "Packs per capita",
    title  = "California Prop 99: observed vs counterfactual paths",
)

band!(ax, years, tasc_lower, tasc_upper;
    color = (:seagreen, 0.20), label = "TASC 95% interval")
lines!(ax, years, california;
    color = :black, linewidth = 3, label = "California (observed)")
lines!(ax, years, sc_cfact;
    color = :steelblue, linewidth = 2, linestyle = :solid, label = "SC counterfactual")
lines!(ax, years, tasc_cfact;
    color = :seagreen, linewidth = 2, label = "TASC counterfactual")
vlines!(ax, [years[T0] + 0.5]; color = :gray40, linestyle = :dash, linewidth = 1)
text!(ax, years[T0] + 0.6, 130; text = "Prop 99", color = :gray40, fontsize = 11)

axislegend(ax; position = :lb, framevisible = false)
save("tasc-prop99.svg", fig)
println("Saved tasc-prop99.svg")

# ── Print ATTs ───────────────────────────────────────────────────────────────
sc_att   = mean(california[(T0+1):end] .- sc_cfact[(T0+1):end])
tasc_att = mean(tasc_cfact[(T0+1):end] .- california[(T0+1):end])  # effect = obs - cfact (negative expected)
tasc_att_correct = mean(california[(T0+1):end] .- tasc_cfact[(T0+1):end])
println("SC ATT:   $(round(sc_att,   digits=2))")
println("TASC ATT: $(round(tasc_att_correct, digits=2))")
