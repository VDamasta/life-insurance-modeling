# Life Insurance Modeling

A Julia project for modeling life insurance products using Belgian actuarial life tables, built as a learning exercise in the Julia language.

## Products

| Product | Function | Description |
|---|---|---|
| Life Annuity | `axn` | Present value of a temporary life annuity |
| Term Insurance | `Axn` | Present value of a term life insurance |
| Pure Endowment | `Exn` | Present value of a pure endowment |

## Life Tables

Six Belgian life tables are loaded from `input/BelgianLifeTables.csv`:

| Variable | Table | Population |
|---|---|---|
| `lt_MR` | MR | Male, Retirement |
| `lt_FR` | FR | Female, Retirement |
| `lt_XR` | XR | Mixed, Retirement |
| `lt_MK` | MK | Male, Capital |
| `lt_FK` | FK | Female, Capital |
| `lt_XK` | XK | Mixed, Capital |

## Usage

```julia
include("LifeInsurance.jl")
using .LifeInsurance

lt = LifeTable([30, 31, 32, 33], [100000, 99000, 97000, 94000], "My Table")

# Survival probability: P(alive at 32 | alive at 30)
pxt(lt, 30, 2)

# Mortality probability: P(dies within 1 year | alive at 30)
qxt(lt, 30, 1)

# Present value of a 10-year life annuity for age 40, i=3%
axn(lt, 40, 10, 0.03)

# Present value of a 10-year term insurance for age 40, i=3%
Axn(lt, 40, 10, 0.03)

# Present value of a pure endowment (survive 10 years) for age 40, i=3%
Exn(lt, 40, 10, 0.03)
```

## Project Structure

```
├── LifeInsurance.jl   # Core module: LifeTable struct and actuarial functions
├── Data.jl            # Data loading, life table construction, benchmarks
├── Tests.jl           # Unit tests
├── Project.toml       # Package dependencies
└── input/
    └── BelgianLifeTables.csv
```

## Running Tests

```julia
julia Tests.jl
```

## Dependencies

- [CSV.jl](https://github.com/JuliaData/CSV.jl)
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)
- [Tables.jl](https://github.com/JuliaData/Tables.jl)
- [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl)

Install all dependencies with:

```julia
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

## Julia Concepts Covered

- Structs with inner constructors and validation
- Multiple dispatch
- Unit testing with `Test`
- Docstrings
- Module system with explicit exports
- Benchmarking with `BenchmarkTools`
