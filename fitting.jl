using Plots

y(x) = 9x^2 + x+ 5
x = 0:0.1:5

scatter_plot = scatter(x, y.(x), xlims = (-0.1, 5.5), ylims = (0, 100), label="True function")

a, b, c = (2, 7, 5)
println("True parameters: a = $a, b = $b, c = $c")

function mutate(value, mutations = 10)
    return [value + (rand() - 0.5) * value * 0.1 for _ in 1:mutations]
end

function mutate(abc::Tuple, number_of_mutations = 10)
    a, b, c = abc
    as = mutate(a, number_of_mutations)
    bs = mutate(b, number_of_mutations)
    cs = mutate(c, number_of_mutations)

    [(as[i], bs[i], cs[i]) for i in 1:number_of_mutations]
end

# Error function
Δ(a, b, c, x, y) = (a * x^2 + b * x + c) - y

function total_error(a, b, c, x, y)
    sum(abs.(Δ.(a, b, c, x, y)))
end

function top_survivors(abcs, x_train, y_train, top_percent = 10)
    errors_and_values = [(total_error(abc..., x_train, y_train), abc) for abc in abcs]
    sorted_errors_and_values = sort(errors_and_values)
    end_number = max(1, Int(floor(length(abcs) * top_percent / 100)))
    sorted_errors_and_values[1:end_number]
end

# Training data
x_train = 0:0.5:5
y_train = y.(x_train)

# Genetic algorithm parameters
generations = 200
population_size = 100
mutation_rate = 0.1

# Initialize population
abc = (rand()*4-2, rand()*14-7, rand()*10)  # Random initial guess
population = mutate(abc, population_size)

# Animation
@gif for gen in 1:generations
    global population, abc
    
    survivors = top_survivors(population, x_train, y_train)
    best_error, abc = survivors[1]
    
    population = vcat([mutate(s[2], Int(floor(population_size / length(survivors)))) for s in survivors]...)
    
    while length(population) < population_size
        push!(population, mutate(abc, 1)[1])
    end
    
    a, b, c = abc
    h(x) = a * x^2 + b * x + c
    p = scatter(x_train, y_train, label="Training data", xlabel="x", ylabel="y", 
                title="Quadratic Fit: Generation $gen\na=$(round(a,digits=3)), b=$(round(b,digits=3)), c=$(round(c,digits=3))")
    plot!(p, x, h.(x), lw=2, label="Current fit")
    plot!(p, x, y.(x), lw=2, ls=:dash, label="True function")
    ylims!(0, 100)
    
    println("Generation $gen: a = $(round(a,digits=3)), b = $(round(b,digits=3)), c = $(round(c,digits=3)), error = $(round(best_error,digits=3))")
end

# Final parameters
a, b, c = abc
println("Final parameters: a = $(round(a,digits=3)), b = $(round(b,digits=3)), c = $(round(c,digits=3))")
