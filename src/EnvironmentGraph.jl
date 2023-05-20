module EnvironmentGraph

using Graphs, MetaGraphs
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

    # First we need to map UUIDs to integers
    # Start with normal dependencies
    n_deps = length(manifest.deps)
    uuid_to_name = Dict{UUID, String}()
    d = Dict{UUID, Int}()
    i = 1
    for (uuid, entry) in manifest.deps
        d[uuid] = i
        uuid_to_name[uuid] = entry.name
        i += 1
    end

    # Then add possible extensions
    for (uuid, entry) in manifest.deps
        for (ext, _) in entry.exts
            uuid_ext = Base.uuid5(uuid, ext)
            d[uuid_ext] = i
            i += 1
        end
    end

    g = MetaDiGraph(Graphs.SimpleGraphs.SimpleDiGraph(i-1))

    for (uuid, pkg) in manifest.deps
        props = Dict(:label => pkg.name, :name => pkg.name, :version => pkg.version, :uuid => uuid, :extension => false)
        du = d[pkg.uuid]
        set_props!(g, du, props)
        for (_, uuid) in pkg.deps
            add_edge!(g, du, d[uuid])
        end
    end

    for (uuid, pkg) in manifest.deps
        # Lookup UUIDs of weak deps
        for (ext, triggers) in pkg.exts
            triggers isa String && (triggers = [triggers])
            all_triggers_present = true
            for trigger in triggers
                uuid_trigger = pkg.weakdeps[trigger]
                if !haskey(d, uuid_trigger)
                    all_triggers_present = false
                    break
                end
            end
            all_triggers_present || continue
            uuid_ext = Base.uuid5(uuid, ext)
            du = d[uuid_ext]
            props = Dict(:label => ext, :name => ext, :version => nothing, :uuid => uuid_ext, :extension => true)
            set_props!(g, du, props)
            add_edge!(g, du, d[pkg.uuid])
            for trigger in triggers
                uuid_trigger = pkg.weakdeps[trigger]
                if haskey(d, uuid_trigger)
                    add_edge!(g, du, d[uuid_trigger])
                end
            end
        end
    end

    return g
end

print_cycles(g) = print_cycles(stdout, g)
function print_cycles(io::IO, g)
    cycles = Graphs.simplecycles(g)
    for c in cycles
        join(io, [props(g, p)[:name] for p in c], " -> ")
        print(io, "↫")
        println()
    end
end

end
