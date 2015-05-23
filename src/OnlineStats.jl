module OnlineStats

import Docile
Docile.@document

import Compat: @compat
import MultivariateStats: fit, PCA
import Distributions:
    # Distributions
    Bernoulli, Beta, Binomial, Dirichlet, Exponential, Gamma, Multinomial,
    MvNormal, Normal, MixtureModel,

    # Other
    fit_dirichlet!, Univariate, Continuous,

    # Methods for DistributionStat
    pdf, cdf, logpdf, loglikelihood, probs, components, params, succprob,
    failprob, scale, location, shape, rate, ncategories, ntrials, dof,
    mean, var, std, mode, modes, skewness, kurtosis, isplatykurtic, ismesokurtic,
    entropy, mgf, cf, insupport, pdf, logpdf, loglikelihood, cdf, logcdf, ccdf,
    logccdf, quantile, cquantile, invlogcdf, invlogccdf, rand, rand!
# import PDMats  # Is this needed?
import DataFrames: DataFrame, names!
import DataArrays
import DataArrays: DataArray
import Base: copy, merge, merge!, show, quantile, maximum, minimum
import Clustering  # kmeans for starting values of NormalMix
import StatsBase
import StatsBase: nobs, skewness, kurtosis, mode, modes, coef, coeftable, confint, predict


#-----------------------------------------------------------------------------#
# Exports
#-----------------------------------------------------------------------------#
export
    # abstract types
    OnlineStat,
    ScalarOnlineStat,
    Weighting,
    EqualWeighting,
    ExponentialWeighting,
    StochasticWeighting,

    # concrete types
    Mean,
    Variance,
    Moments,
    Extrema,
    Summary,
    QuantileMM,
    QuantileSGD,
    FiveNumberSummary,

    CovarianceMatrix,
    Means,
    Variances,
    AnalyticalPCA,

    NormalMix,
    FitBernoulli,
    FitBeta,
    FitBinomial,
    FitDirichlet,
    FitExponential,
    FitGamma,
    FitMultinomial,
    FitMvNormal,
    FitNormal,

    OnlineFLS,
    LinReg,
    LinRegSGD,
    QuantRegSGD,
    QuantRegMM,

    # functions
    nobs,
    update!,
    updatebatch!,
    state,
    statenames,
    onlinefit,
    tracedata,
    unpack_vectors,
    em,
    means,
    stds,
    smooth,
    smooth!,
    weighting,
    sweep!


#-----------------------------------------------------------------------------#
# Source files
#-----------------------------------------------------------------------------#

include("log.jl")

# Abstract Types
include("types.jl")
include("weighting.jl")

# Other
include("tracedata.jl")
include("common.jl")

# Summary Statistics
include("summary/mean.jl")
include("summary/var.jl")
include("summary/extrema.jl")
include("summary/summary.jl")
include("summary/moments.jl")
include("summary/quantilesgd.jl")
include("summary/quantilemm.jl")
include("summary/fivenumber.jl")

# Multivariate
include("multivariate/covmatrix.jl")
include("multivariate/means.jl")
include("multivariate/vars.jl")
include("multivariate/analyticalpca.jl")

# Parametric Density
include("distributions/bernoulli.jl")
include("distributions/beta.jl")
include("distributions/binomial.jl")
include("distributions/dirichlet.jl")
include("distributions/exponential.jl")
include("distributions/gamma.jl")
include("distributions/multinomial.jl")
include("distributions/mvnormal.jl")
include("distributions/normal.jl")
include("distributions/offlinenormalmix.jl")
include("distributions/normalmix.jl")

# Linear Model
include("linearmodel/sweep.jl")
include("linearmodel/linregsgd.jl")
include("linearmodel/linreg.jl")
# include("linearmodel/sparsereg.jl")
# include("linearmodel/ridge.jl")
include("linearmodel/ofls.jl")
include("linearmodel/opca.jl")
include("linearmodel/opls.jl")

# GLM
# include("glm/logisticregsgd.jl")
# include("glm/logisticregmm.jl")
# include("glm/logisticregsn.jl")

# Quantile Regression
include("quantileregression/quantregsgd.jl")
include("quantileregression/quantregmm.jl")



end # module
