# EnvironmentGraph

```jl
(EnvironmentGraph) pkg> activate --temp
  Activating new project at `/tmp/jl_mG82U9`

(jl_mG82U9) pkg> add MKL
   Resolving package versions...
    Updating `/tmp/jl_mG82U9/Project.toml`
  [33e6dc65] + MKL v0.4.1

julia> g = EnvironmentGraph.environment_graph("/tmp/jl_mG82U9/")
{39, 100} directed Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)

julia> EnvironmentGraph.print_cycles(g)
Pkg -> p7zip_jll↫
Pkg -> Downloads -> LibCURL -> MozillaCACerts_jll↫
Pkg -> Downloads -> LibCURL -> LibCURL_jll↫
Pkg -> Downloads -> LibCURL -> LibCURL_jll -> LibSSH2_jll↫
Pkg -> Downloads -> LibCURL -> LibCURL_jll -> LibSSH2_jll -> MbedTLS_jll↫
Pkg -> Downloads -> LibCURL -> LibCURL_jll -> MbedTLS_jll↫
Pkg -> Downloads -> LibCURL -> LibCURL_jll -> nghttp2_jll↫
Pkg -> Downloads -> LibCURL -> LibCURL_jll -> Zlib_jll↫
```
