if VERSION < v"0.7-"
    Pkg.clone("https://github.com/daanhb/BasisFunctions.jl")
    Pkg.checkout("BasisFunctions", "development")
    Pkg.build("BasisFunctions")
end
run(`rm -f '~/.jupyter/jupyter_nbconvert_config.json'`)
