using Aqua: Aqua
using PkgDependents: PkgDependents
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(PkgDependents)
end
