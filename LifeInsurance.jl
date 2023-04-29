"""
    LifeTable

    A life table contaning the age (x) and number of people alive at that age (lx)

    # Examples
    ```julia-repl
    julia> LifeTable([30, 31, 32], [0.97, 0.96, 0.9], "My Life Table")
    ```
"""
struct LifeTable
    x::Vector{Int}
    lx::Vector{Float64}
    name::String

    function LifeTable(x::Vector{Int}, lx::Vector{Float64}, name::String)
        check = String[]

        if length(x) != length(lx) 
            push!(check, "Length of x and lx must be the same") 
        end

        if any(diff(lx) .>= 0)
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
    julia> lt = LifeTable([30, 31, 32], [0.97, 0.96, 0.9], "My Life Table")
    julia> pxt(lt, 30, 2)
    ```
"""
function pxt(lt::LifeTable, x::Int, t::Int)
    ageIndex = findfirst(item -> item == x, lt.x)
    surviveIndex = findfirst(item -> item == x + t, lt.x)

    lx = lt.lx[ageIndex]
    lxt = lt.lx[surviveIndex]
    return lxt/lx
end

function qxt(lt::LifeTable, x::Int, t::Int)
        1 - pxt(lt,x,t) 
end

function axn(lt::LifeTable, x::Int, n::Int, i::Float64) 
    pxt = pxt(lt, x,t)

    
end
