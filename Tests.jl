using Test

# test valid input
function test_valid_input()
    lt = LifeTable([1, 2, 3], [0.95, 0.90, 0.85], "Test Table")
    @test lt.x == [1, 2, 3]
    @test lt.lx == [0.95, 0.90, 0.85]
    @test lt.name == "Test Table"
end

# test unequal length
function test_unequal_length()
    @test_throws ErrorException LifeTable([1, 2, 3], [0.95, 0.90], "Invalid Table")
end

# test non-decreasing lx
function test_non_decreasing_lx()
    @test_throws ErrorException LifeTable([1, 2, 3], [0.95, 0.90, 0.90], "Invalid Table")
end

# test non-consecutive x
function test_non_consecutive_x()
    @test_throws ErrorException LifeTable([1, 3, 5], [0.95, 0.90, 0.85], "Invalid Table")
end


# run tests
@testset "LifeTable tests" begin
    test_valid_input()
    test_unequal_length()
    test_non_decreasing_lx()
    test_non_consecutive_x()
end

## createa 
