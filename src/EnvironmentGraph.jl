module EnvironmentGraph

using LightGraphs, MetaGraphs
using TOML
using Pkg
using UUIDs

function environment_graph(env::String)
    manifest_file = joinpath(env, "Manifest.toml")
    if !isfile(manifest_file)
       error("expected a `Manifest.toml` file at $(abspath(env))")
    end
    project_file = joinpath(env, "Project.toml")
    if !isfile(project_file)
        error("expected a `Project.toml` file at $(abspath(env))")
    end
    manifest = Pkg.Types.read_manifest(manifest_file)
    project = Pkg.Types.read_project(project_file)

    n_deps = length(manifest.deps)
    d = Dict{UUID, Int}()
    for (i, (uuid, _)) in enumerate(manifest.deps)
        d[uuid] = i
    end

    g = MetaDiGraph(LightGraphs.SimpleGraphs.SimpleDiGraph(n_deps))

    for (uuid, pkg) in manifest.deps
        props = Dict(:name => pkg.name, :version => pkg.version, :uuid => uuid)
        du = d[pkg.uuid]
        set_props!(g, du, props)
        for (dep_name, uuid) in pkg.deps
            add_edge!(g, du, d[uuid])
        end
        isdefined(pkg, :weakdeps) && for (dep_name, uuid) in pkg.weakdeps
            haskey(d, uuid) && add_edge!(g, du, d[uuid])
        end
    end

    return g
end

print_cycles(g) = print_cycles(stdout, g)
function print_cycles(io::IO, g)
    cycles = LightGraphs.simplecycles(g)
    for c in cycles
        join(io, [props(g, p)[:name] for p in c], " -> ")
        print(io, "↫")
        println()
    end
end

end
