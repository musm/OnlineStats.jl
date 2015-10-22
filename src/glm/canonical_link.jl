# Online MM gradient algorithm for OnlineGLMs with canonical link
const _supported_dists = [
    Distributions.Normal,
    Distributions.Bernoulli,
    Distributions.Poisson
]

type OnlineGLM{D <: Distributions.UnivariateDistribution} <: OnlineStat
    β::VecF
    dist::D
    weighting::LearningRate
    n::Int
end

function OnlineGLM(p::Integer, wgt::LearningRate = LearningRate();
        family::Distributions.UnivariateDistribution = Distributions.Normal(),
        start = zeros(p)
    )
    typeof(family) in _supported_dists || error("$(typeof(family)) is not supported for OnlineGLM")
    OnlineGLM(start, family, wgt, 0)
end

function OnlineGLM(x::AMatF, y::AVecF, wgt::LearningRate = LearningRate(); kw...)
    o = OnlineGLM(size(x, 2), wgt; kw...)
    update!(o, x, y)
    o
end

#----------------------------------------------------------------------# update!
function update!(o::OnlineGLM, x::AVec, y::Float64)
end

function update!(o::OnlineGLM{Distributions.Poisson}, x::AVec, y::Float64, γ::Float64 = weight(o))
    ŷ = predict(o, x)
    u = γ * (y - ŷ) / (sumabs2(x) * ŷ)

    for j in 1:length(x)
        o.β[j] += x[j] * u
    end
    o.n += 1
end

function update!(o::OnlineGLM{Distributions.Bernoulli}, x::AVec, y::Float64, γ::Float64 = weight(o))
    ŷ = predict(o, x)
    u = γ * (y - ŷ) / (sumabs2(x) * ŷ * (1 - ŷ))

    for j in 1:length(x)
        o.β[j] += x[j] * u
    end
    o.n += 1
end

function update!(o::OnlineGLM{Distributions.Normal}, x::AVec, y::Float64, γ::Float64 = weight(o))
    u = γ * (y - predict(o, x)) / sumabs2(x)
    for j in 1:length(x)
        o.β[j] += x[j] * u
    end
    o.n += 1
end

#------------------------------------------------------------------------# state
statenames(o::OnlineGLM) = [:β, :nobs]
state(o::OnlineGLM) = Any[coef(o), nobs(o)]
StatsBase.coef(o::OnlineGLM) = copy(o.β)

StatsBase.predict(o::OnlineGLM, x::AMatF) = [predict(o,rowvec_view(x, i)) for i in 1:size(x, 1)]
StatsBase.predict(o::OnlineGLM{Distributions.Poisson}, x::AVecF) = exp(dot(x, coef(o)))
StatsBase.predict(o::OnlineGLM{Distributions.Normal}, x::AVecF) = dot(x, coef(o))
StatsBase.predict(o::OnlineGLM{Distributions.Bernoulli}, x::AVecF) = 1.0 / (1.0 + exp(-dot(x, coef(o))))





######################### TESTING
if false
    n, p = 1_000_000, 5
    x = randn(n, p)
    β = vcat(1.:p) / p

    # POISSON
    # y = Float64[rand(Distributions.Poisson(exp(xb))) for xb in x*β]
    # o = OnlineStats.OnlineGLM(p, OnlineStats.LearningRate(r=.8), family = Distributions.Poisson())
    # @time OnlineStats.update!(o, x, y)
    # o2 = OnlineStats.StochasticModel(x,y,model = OnlineStats.PoissonRegression(), algorithm = OnlineStats.SGD(r=.7), intercept = false)
    # o3 = OnlineStats.StochasticModel(x,y,model = OnlineStats.PoissonRegression(), algorithm = OnlineStats.ProxGrad(), intercept = false)
    # o4 = OnlineStats.StochasticModel(x,y,model = OnlineStats.PoissonRegression(), algorithm = OnlineStats.RDA(), intercept = false)

    # BERNOULLI
    # y = Float64[rand(Distributions.Bernoulli(1 / (1 + exp(-xb)))) for xb in x*β]
    # @time o = OnlineStats.OnlineGLM(x, y, OnlineStats.LearningRate(r=.8), family = Distributions.Bernoulli())
    # o2 = OnlineStats.StochasticModel(x,y,model = OnlineStats.LogisticRegression(), algorithm = OnlineStats.SGD(r=.7), intercept = false)
    # o3 = OnlineStats.StochasticModel(x,y,model = OnlineStats.LogisticRegression(), algorithm = OnlineStats.ProxGrad(), intercept = false)
    # o4 = OnlineStats.StochasticModel(x,y,model = OnlineStats.LogisticRegression(), algorithm = OnlineStats.RDA(), intercept = false)

    NORMAL
    y = x * β + randn(n)
    o = OnlineStats.OnlineGLM(p, OnlineStats.LearningRate(r=.7))
    @time OnlineStats.update!(o, x, y)
    o2 = OnlineStats.StochasticModel(x, y, algorithm = OnlineStats.SGD(), intercept = false)
    o3 = OnlineStats.StochasticModel(x, y, algorithm = OnlineStats.ProxGrad(), intercept = false)
    o4 = OnlineStats.StochasticModel(x, y, algorithm = OnlineStats.RDA(), intercept = false)

    println("\n\n")
    println("maxabs(β - coef(o)) for")
    println()
    println("glm:      ", maxabs(β - coef(o)))
    println("sgd:      ", maxabs(β - coef(o2)))
    println("proxgrad: ", maxabs(β - coef(o3)))
    println("rda:      ", maxabs(β - coef(o4)))
end #if