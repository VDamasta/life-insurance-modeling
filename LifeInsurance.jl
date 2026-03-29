"""
    LifeTable

    A life table containing the age (x) and number of people alive at that age (lx) from a cohort of people

    # Examples
    ```julia-repl
    julia> LifeTable([30, 31, 32], [0.97, 0.96, 0.9], "My Life Table")
    ```
"""
struct LifeTable
    x::Vector{Int}
    lx::Vector{Float64}
    name::String

    function LifeTable(x::Vector{Int}, lx::Vector{Int}, name::String)
        check = String[]

        if length(x) != length(lx)
            push!(check, "Length of x and lx must be the same")
        end

        if any(diff(lx) .> 0)
            push!(check, "lx must be a decreasing sequence")
        end

        if any(diff(x) .!= 1)
            push!(check, "x must be consecutive integers")
        end

        if length(check) >= 1
            error(check)
        end

        new(x, lx, name)
    end
end


"""
    pxt

    Survival probability of a person aged x until time t

    # Examples
    ```julia-repl
    julia> lt = LifeTable([30, 31, 32], [97000, 96000, 90000], "My Life Table")
    julia> pxt(lt, 30, 2)
    ```
"""
function pxt(lt::LifeTable, x::Int, t::Int)
    ageIndex = findfirst(item -> item == x, lt.x)
    surviveIndex = findfirst(item -> item == x + t, lt.x)

    lx = lt.lx[ageIndex]
    lxt = lt.lx[surviveIndex]
    lx == 0 ? prob = 1 : prob = lxt/lx
    return prob
end


"""
    qxt

    Mortality probability of a person aged x within t years (complement of pxt)

    # Examples
    ```julia-repl
    julia> lt = LifeTable([30, 31, 32], [97000, 96000, 90000], "My Life Table")
    julia> qxt(lt, 30, 1)
    ```
"""
function qxt(lt::LifeTable, x::Int, t::Int)
    return 1 - pxt(lt,x,t)
end

function axn(lt::LifeTable, x::Int, n::Int, i::Float64)
    v = 1/(1+i)
    PV = 0
    for term in 1:n
        survivalProb = pxt(lt,x,term)
        disc = v^term
        PV += survivalProb * disc
    end

    return PV
end

"""
    Axn

    Present value of a term life insurance paying 1 upon death of a person aged x, over n years, at interest rate i

    # Examples
    ```julia-repl
    julia> lt = LifeTable([30, 31, 32], [97000, 96000, 90000], "My Life Table")
    julia> Axn(lt, 30, 2, 0.03)
    ```
"""
function Axn(lt::LifeTable, x::Int, n::Int, i::Float64)
    v = 1/(1+i)
    PV = 0
    for term in 1:n
        survivalProb = pxt(lt,x,term-1)
        deathProb = qxt(lt,x + term-1,1)
        disc = v^term
        PV += survivalProb * deathProb * disc
    end

    return PV
end

"""
    Exn

    Present value of a pure endowment paying 1 if a person aged x survives n years, at interest rate i

    # Examples
    ```julia-repl
    julia> lt = LifeTable([30, 31, 32], [97000, 96000, 90000], "My Life Table")
    julia> Exn(lt, 30, 2, 0.03)
    ```
"""
function Exn(lt::LifeTable, x::Int, n::Int, i::Float64)
    v = 1/(1+i)
    survivalProb = pxt(lt,x,n)
    disc = v^n
    PV = survivalProb * disc

    return PV
end
