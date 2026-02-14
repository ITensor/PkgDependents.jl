using PkgDependents: dependencies, dependents
using Test: @test, @testset

@testset "PkgDependents" begin
    @test "ZygoteRules" ∈ dependencies("Zygote")
    @test "Flux" ∈ dependents("Zygote")
end
