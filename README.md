# Life Insurance Modeling

A Julia project for modeling life insurance products using Belgian actuarial life tables, built as a learning exercise in the Julia language.

## Products

### Building blocks

| Function | Description |
|---|---|
| `pxt(lt, x, t, i)` | Survival probability: P(alive at x+t \| alive at x) |
| `qxt(lt, x, t, i)` | Mortality probability: 1 - pxt |

### Insurance products

| Function | Description |
|---|---|
| `Axn(lt, x, n, i)` | Term life insurance — pays 1 on death within n years |
| `Ax(lt, x, i)` | Whole life insurance — pays 1 on death at any age |
| `Exn(lt, x, n, i)` | Pure endowment — pays 1 if alive after n years |
| `AExn(lt, x, n, i)` | Endowment insurance — pays 1 on death OR survival (= Axn + Exn) |

### Annuity products

| Function | Description |
|---|---|
| `axn(lt, x, n, i)` | Temporary life annuity — pays 1/year for up to n years |
| `ax(lt, x, i)` | Whole life annuity — pays 1/year for life |
| `m_axn(lt, x, m, n, i)` | Deferred temporary annuity — starts after m years, pays for n years |

### Pricing & reserving

| Function | Description |
|---|---|
| `Pxn(lt, x, n, i)` | Net level annual premium for a term insurance (= Axn / axn) |
| `Vt(lt, x, n, t, i)` | Prospective policy reserve at time t |

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

# Present value of a 10-year temporary life annuity, age 40, i=3%
axn(lt, 40, 10, 0.03)

# Present value of a whole life annuity, age 40, i=3%
ax(lt, 40, 0.03)

# Present value of a 10-year temporary life annuity deferred 5 years, age 40, i=3%
m_axn(lt, 40, 5, 10, 0.03)

# Present value of a 10-year term insurance, age 40, i=3%
Axn(lt, 40, 10, 0.03)

# Present value of a whole life insurance, age 40, i=3%
Ax(lt, 40, 0.03)

# Present value of a pure endowment (survive 10 years), age 40, i=3%
Exn(lt, 40, 10, 0.03)

# Present value of a 10-year endowment insurance, age 40, i=3%
AExn(lt, 40, 10, 0.03)

# Net level annual premium for a 10-year term insurance, age 40, i=3%
Pxn(lt, 40, 10, 0.03)

# Prospective policy reserve at time 5 for a 10-year term insurance, age 40, i=3%
Vt(lt, 40, 10, 5, 0.03)
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
