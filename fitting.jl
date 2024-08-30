using Plots

y(x)=7x+5
x = 0:0.1:5

scatter_plot = scatter(x, y.(x), xlims = (-0.1, 5.5), ylims = (0, 50))

m, c = (7,5)
println("m = ", m)
println("c = ", c)

function mutate(value, mutations = 10)
    return [value + rand() - 0.5 for index in 1:mutations]
end

function mutate(mc::Tuple, number_of_mutations = 10)
    m, c = mc
    ms = mutate(m, number_of_mutations)
    cs = mutate(c, number_of_mutations)

    [(ms[index], cs[index]) for index in 1:number_of_mutations]
end

mutate(5)
mutate((8,2))

∆(m, c, x, y) = (m * x + c) - y
∆(5, 4, 10, y(10))

function total_error(m, c, x, y)
    ΣΔ = 0

    for i in eachindex(x)
        ΣΔ += abs(∆(m, c, x[i], y[i]))
    end

    ΣΔ
end

function top_survivors(mcs, x_train, y_train, top_percent = 10)
    errors_and_values = []

    for mc in mcs
        m, c = mc
        error = total_error(m, c, x_train, y_train)
        push!(errors_and_values, (error, mc))
    end


    sorted_errors_and_values = sort(errors_and_values)
    end_number = Int(length(mcs) * top_percent / 100)
    sorted_errors_and_values[1:end_number]
end

x_train = [1, 2, 3, 4, 5]
y_train = y.(x_train)
mcs = mutate((0, 0))

top_survivors(mcs, x_train, y_train)


generations = 40

top_survivor = Nothing
mc = (0, 0)

@gif for i in 1:generations
    mcs = mutate(mc)
    top_survivor = top_survivors(mcs, x_train, y_train)[1]
    _error, mc = top_survivor

    hm, hc = mc
    p = scatter(x_train, y_train)
    h(x) = hm * x + hc
    plot!(p, x, h.(x), ylims = (0, 50))
end