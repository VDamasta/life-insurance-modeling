using Test

include("LifeInsurance.jl")
using .LifeInsurance

# Shared test life table
lt = LifeTable([30, 31, 32, 33, 34], [100000, 99000, 97000, 94000, 90000], "Test Table")

@testset "LifeTable construction" begin
    @test lt.x == [30, 31, 32, 33, 34]
    @test lt.lx == [100000.0, 99000.0, 97000.0, 94000.0, 90000.0]
    @test lt.name == "Test Table"

    # accepts floats
    lt_f = LifeTable([1, 2, 3], [0.95, 0.90, 0.85], "Float Table")
    @test lt_f.lx == [0.95, 0.90, 0.85]

    # unequal length
    @test_throws ErrorException LifeTable([1, 2, 3], [95000, 90000], "Bad Table")

    # non-strictly decreasing lx (equal values not allowed)
    @test_throws ErrorException LifeTable([1, 2, 3], [95000, 90000, 90000], "Bad Table")

    # increasing lx
    @test_throws ErrorException LifeTable([1, 2, 3], [90000, 95000, 99000], "Bad Table")

    # non-consecutive x
    @test_throws ErrorException LifeTable([1, 3, 5], [95000, 90000, 85000], "Bad Table")
end

@testset "pxt" begin
    # t=0: certain survival
    @test pxt(lt, 30, 0) ≈ 1.0

    # t=1: 99000/100000
    @test pxt(lt, 30, 1) ≈ 0.99

    # t=4: 90000/100000
    @test pxt(lt, 30, 4) ≈ 0.90

    # age out of table
    @test_throws ErrorException pxt(lt, 25, 1)

    # target age out of table
    @test_throws ErrorException pxt(lt, 32, 5)
end

@testset "qxt" begin
    # complement of pxt
    @test qxt(lt, 30, 1) ≈ 1 - pxt(lt, 30, 1)
    @test qxt(lt, 30, 4) ≈ 0.10
end

@testset "axn" begin
    # with i=0 PV equals sum of survival probs
    pv_no_disc = axn(lt, 30, 4, 0.0)
    expected = pxt(lt,30,1) + pxt(lt,30,2) + pxt(lt,30,3) + pxt(lt,30,4)
    @test pv_no_disc ≈ expected

    # higher interest rate produces lower PV
    @test axn(lt, 30, 4, 0.05) < axn(lt, 30, 4, 0.01)
end

@testset "Axn" begin
    # with i=0 PV equals sum of death probs (= 1 - survival to end)
    pv_no_disc = Axn(lt, 30, 4, 0.0)
    expected = qxt(lt, 30, 4)
    @test pv_no_disc ≈ expected

    # higher interest rate produces lower PV
    @test Axn(lt, 30, 4, 0.05) < Axn(lt, 30, 4, 0.01)
end

@testset "Exn" begin
    # with i=0 PV equals survival probability
    @test Exn(lt, 30, 4, 0.0) ≈ pxt(lt, 30, 4)

    # higher interest rate produces lower PV
    @test Exn(lt, 30, 4, 0.05) < Exn(lt, 30, 4, 0.01)

    # actuarial identity: Axn + i*axn ≈ 1 - Exn (approximately for small i)
    i = 0.03
    @test Axn(lt, 30, 4, i) + Exn(lt, 30, 4, i) ≤ 1.0
end

@testset "ax" begin
    # whole life annuity >= temporary annuity for same age
    @test ax(lt, 30, 0.03) >= axn(lt, 30, 2, 0.03)

    # with i=0 equals sum of all survival probs to end of table
    pv_no_disc = ax(lt, 30, 0.0)
    expected = sum(pxt(lt, 30, t) for t in 1:(lt.x[end] - 30))
    @test pv_no_disc ≈ expected
end

@testset "Ax" begin
    # whole life insurance >= term insurance for same age
    @test Ax(lt, 30, 0.03) >= Axn(lt, 30, 2, 0.03)

    # with i=0 certain death so PV = 1 (everyone eventually dies)
    @test Ax(lt, 30, 0.0) ≈ 1.0
end

@testset "AExn" begin
    # equals Axn + Exn by definition
    i = 0.03
    @test AExn(lt, 30, 4, i) ≈ Axn(lt, 30, 4, i) + Exn(lt, 30, 4, i)

    # with i=0, AExn = 1 (either dies or survives, so certain payout)
    @test AExn(lt, 30, 4, 0.0) ≈ 1.0
end

@testset "m_axn" begin
    # deferred annuity with m=0 equals temporary annuity
    @test m_axn(lt, 30, 0, 4, 0.03) ≈ axn(lt, 30, 4, 0.03)

    # deferred annuity is always less than non-deferred (discounting + mortality)
    @test m_axn(lt, 30, 1, 3, 0.03) < axn(lt, 30, 3, 0.03)
end

@testset "Pxn" begin
    # premium is positive
    @test Pxn(lt, 30, 4, 0.03) > 0.0

    # premium = Axn / axn
    i = 0.03
    @test Pxn(lt, 30, 4, i) ≈ Axn(lt, 30, 4, i) / axn(lt, 30, 4, i)

    # higher interest rate increases premium (discount reduces annuity more than insurance)
    @test Pxn(lt, 30, 4, 0.05) > Pxn(lt, 30, 4, 0.01)
end

@testset "Vt" begin
    i = 0.03

    # reserve at t=0 should be 0 (no payments made yet, equivalence principle)
    @test Vt(lt, 30, 4, 0, i) ≈ 0.0 atol=1e-10

    # reserve at t=n should be 0 (policy expired)
    @test Vt(lt, 30, 4, 4, i) ≈ 0.0

    # reserve increases over time (for term insurance)
    @test Vt(lt, 30, 4, 2, i) >= Vt(lt, 30, 4, 1, i)
end
