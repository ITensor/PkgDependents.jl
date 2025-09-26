using PkgDependents: PkgDependents
using Aqua: Aqua
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
  Aqua.test_all(PkgDependents)
end
