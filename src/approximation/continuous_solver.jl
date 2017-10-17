
function continuous_approximation_operator(dest::ExtensionFrame; sampling_factor=1, solver=FrameFun.FE_DirectSolver, options...)
    # since the other one is not very efficient (this one isnt either), concider this not as a general case
    (sampling_factor ≈ 1) &&
        (return ContinuousSolverPlan(solver(MixedGram(dest; options...); options...), continuous_normalization(dest; options...)))
    src = resize(dest, round(Int, sampling_factor*length(dest)))
    println(sampling_factor)
    ContinuousSolverPlan(solver(MixedGram(dest, src; options...); options...), continuous_normalization(src; options...))
end

continuous_normalization(set::FunctionSet; options...) = DualGram(set; options...)
continuous_normalization(frame::ExtensionFrame; options...) = DualGram(basis(frame); options...)

immutable ContinuousSolverPlan{T} <: AbstractOperator{T}
    src                     :: FunctionSet
    dest                    :: FunctionSet
    mixedgramsolver         :: FE_Solver
    normalizationofb        :: AbstractOperator

    scratch                 :: Vector{T}
    mixedgram               :: AbstractOperator
    ContinuousSolverPlan{T}(src::FunctionSet, dest::FunctionSet, mixedgramsolver::FE_Solver, normalizationofb::AbstractOperator) where {T} =
        new(src, dest, mixedgramsolver, normalizationofb, zeros(T, length(src)), mixedgramsolver.op)
end

ContinuousSolverPlan(solver::FE_Solver{T}, normalization::AbstractOperator) where {T} =
    ContinuousSolverPlan(src(solver), dest(solver), solver, normalization)

ContinuousSolverPlan(src::FunctionSet, dest::FunctionSet, solver::FE_Solver{T}, normalization::AbstractOperator) where {T} =
    ContinuousSolverPlan{T}(src, dest, solver, normalization)

function apply!(s::ContinuousSolverPlan, coef_dest, coef_src)
    apply!(s.normalizationofb, s.scratch, coef_src)
    coef_dest[:] = s.mixedgramsolver*s.scratch
    # println(norm(s.mixedgram*coef_dest-s.scratch))
end