normalized_discretization(ss::SamplingStyle, ap::ApproximationProblem; options...) =
    normalized_discretization(ss, ap, haskey(options,:S) ? options[:S] : samplingoperator(ss, ap; options...); options...)
normalized_discretization(f, ss::SamplingStyle, ap::ApproximationProblem; options...) =
    normalized_discretization(f, ss, ap, haskey(options,:S) ? options[:S] : samplingoperator(ss, ap; options...); options...)
normalized_dualdiscretization(ss::SamplingStyle, ap::ApproximationProblem; options...) =
    normalized_dualdiscretization(ss, ap, haskey(options,:S) ? options[:S] : samplingoperator(ss, ap; options...); options...)

function normalized_discretization(ss::SamplingStyle, ap::ApproximationProblem, S::AbstractOperator; normalizedsampling=default_aznormalization(ap), options...)
    D = discretization(ss, ap, S; options...)
    if normalizedsampling
        normalizationoperator(ss, ap; S=S,options...)*D
    else
        D
    end
end

function normalized_dualdiscretization(ss::SamplingStyle, ap::ApproximationProblem, S::AbstractOperator; normalizedsampling=default_aznormalization(ap), options...)
    D = dualdiscretization(ss, ap, S; options...)
    if normalizedsampling
        inv(normalizationoperator(ss, ap; S=S,options...))*D
    else
        D
    end
end

function normalized_discretization(f, ss::SamplingStyle, ap::ApproximationProblem, S::AbstractOperator; normalizedsampling=default_aznormalization(ap), options...)
    D,b = discretization(f, ss, ap, S; options...)
    if normalizedsampling
        N = normalizationoperator(ss, ap; S=S,options...)
        N*D, N*b
    else
        D, b
    end
end
