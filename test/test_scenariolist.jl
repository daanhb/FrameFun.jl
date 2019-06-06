using BasisFunctions, LinearAlgebra, DomainSets, GridArrays, Test, StaticArrays, FrameFun
@testset begin
    B = Fourier(11,-1,1)⊗Fourier(11,-1,1)
    Dom = disk(0.8)
    @test support(dictionary(∂x(random_expansion(extensionframe(B, Dom)))))≈Dom

    @test dictionary(FrameFun.approximationproblem(Fourier(100),0.0..0.5)) == extensionframe(Fourier(100),0.0..0.5)
    # Test defaults
    @test AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=false)≈
        AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5))


    A = AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=false)
    L = samplingparameter(OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5))
    a1 = evaluation_operator(Fourier(L),interpolation_grid(Fourier(L)))
    a2 = IndexRestrictionOperator(GridBasis(interpolation_grid(Fourier(L))),1:200)
    a3 = BasisFunctions.FourierIndexExtensionOperator(Fourier(100),Fourier(L))
    @test A≈a2*a1*a3

    A = AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=true)
    L = samplingparameter(OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5))
    a1 = evaluation_operator(Fourier(L),interpolation_grid(Fourier(L)))
    a2 = IndexRestrictionOperator(GridBasis(interpolation_grid(Fourier(L))),1:200)
    a3 = BasisFunctions.FourierIndexExtensionOperator(Fourier(100),Fourier(L))
    a4 = ScalingOperator(dest(a2),1/sqrt(L))
    @test A≈a4*a2*a1*a3

    # Test differnence normalizationoperator
    s = svdvals(AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=false))
    N = FrameFun.normalizationoperator(OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5))
    L = samplingparameter(OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5))
    @test N isa DictionaryOperator
    @test N[1,1] ≈ 1/sqrt(L)
    @test L == 399
    @test 47==sum(s.<.1*sqrt(L))
    @test 49==sum(s.>.9*sqrt(L))

    s = svdvals(AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=true))
    @test 47==sum(s.<.1)
    @test 49==sum(1+1e-10 .> s .>.9)

    # right side should be appropriately noralized
    @test discretization(exp, OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5);oversamplingfactor=2,normalizedsampling=true)[2]≈
        1/sqrt(399)*GridSampling(subgrid(interpolation_grid(Fourier(399)),0.0..0.5))*exp

    # left side should be appropriately noralized
    @test AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=true)≈
        discretization(exp, OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5);oversamplingfactor=2,normalizedsampling=true)[1]


    # right side should be appropriately noralized
    @test discretization(exp, OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5);oversamplingfactor=2,normalizedsampling=false)[2]≈
        GridSampling(subgrid(interpolation_grid(Fourier(399)),0.0..0.5))*exp

    # left side should be appropriately noralized
    @test AZ_A(FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=false)≈
        discretization(exp, OversamplingStyle(),FrameFun.approximationproblem(Fourier(100),0.0..0.5);oversamplingfactor=2,normalizedsampling=false)[1]


    F = approximate(exp,FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=true)
    @test abs(F[1](.2)-exp(.2) )< 1e-12


    F = approximate(exp,FrameFun.approximationproblem(Fourier(100),0.0..0.5);samplingstyle=OversamplingStyle(),oversamplingfactor=2,normalizedsampling=false)
    @test abs(F[1](.2)-exp(.2) )< 1e-12

end
