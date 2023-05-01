using CSV
using DataFrames
using BenchmarkTools

include("LifeInsurance.jl")

# Load data 
BelgianLifeTables = CSV.read("input\\BelgianLifeTables.csv", DataFrame)

# Create Life Tables

lt_MR =  LifeTable(BelgianLifeTables.x, BelgianLifeTables.MR,"MR Table") 
lt_FR =  LifeTable(BelgianLifeTables.x, BelgianLifeTables.FR,"FR Table") 
lt_XR =  LifeTable(BelgianLifeTables.x, BelgianLifeTables.XR,"XR Table") 

lt_MK =  LifeTable(BelgianLifeTables.x, BelgianLifeTables.MK,"MK Table") 
lt_FK =  LifeTable(BelgianLifeTables.x, BelgianLifeTables.FK,"FK Table") 
lt_XK =  LifeTable(BelgianLifeTables.x, BelgianLifeTables.FK,"XK Table") 

# Generate fake data

sample_size = 10_000
sample_data = let
    # generate fake data
    df = DataFrame(
        "sex" => rand(["Male","Female"],sample_size),
        "age" => rand(25:55,sample_size),
        "term" => rand(10:50,sample_size),
        )
    
    df
end

# Simulation

lt_map = Dict(
    "Male" => lt_MR,
    "Female" => lt_XR
);

# method 1
pv = [];
@benchmark for policy in eachrow(sample_data)
    value = axn(lt_map[policy.sex],policy.age, policy.term,0.03)
    push!(pv,value)
end

sample_data[!, :PV] = pv  

# method 2 using tables with type safe iterator
tbl = Tables.rowtable(sample_data)
pv = [];
@benchmark  for policy in Tables.rows(tbl)
    value = axn(lt_map[policy.sex],policy.age, policy.term,0.03)
    push!(pv,value) 
end

# Benchmark 

age = 10
term = 10
i = 0.03

@benchmark axn(lt_XR,$age,$term,$i)
@benchmark Exn(lt_XR,$age,$term,$i)
@benchmark Axn(lt_XR,$age,$term,$i)

@btime axn(lt_XR,$age,$term,$i)
