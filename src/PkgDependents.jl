module PkgDependents

using RegistryInstances: RegistryInstances

function uuid_from_pkgname(
  pkgname::String; registries=RegistryInstances.reachable_registries()
)
  uuid_to_registrynames = Dict{Base.UUID,Vector{String}}()
  for registry in registries
    registry_uuids = RegistryInstances.uuids_from_name(registry, pkgname)
    if !isempty(registry_uuids)
      # There should only be one package with a given UUID in a given
      # registry.
      registry_uuid = only(registry_uuids)
      if !haskey(uuid_to_registrynames, registry_uuid)
        uuid_to_registrynames[registry_uuid] = [registry.name]
      else
        push!(uuid_to_registrynames[registry_uuid], registry.name)
      end
    end
  end
  if !isone(length(uuid_to_registrynames))
    # Multiple UUIDs exist across different registries.
    # Prefer the version in the general registry.
    for (uuid, registrynames) in pairs(uuid_to_registrynames)
      if "General" ∈ registrynames
        return uuid
      end
    end
  end
  return only(keys(uuid_to_registrynames))
end

function registryinstance_from_pkgname(
  pkgname::String; registries=RegistryInstances.reachable_registries()
)
  # Make sure the UUID is the same across registries.
  # If multiple registries contain the package, select
  # the one from General.
  uuid = uuid_from_pkgname(pkgname; registries)
  # Find the registries that have packages with this UUID.
  registries′ = filter(registries) do registry
    haskey(registry, uuid)
  end
  # Choose the registry with the largest registered version of
  # this package.
  return argmax(registries′) do registry
    # Get the maximum version number registered in this registry.
    return maximum(keys(RegistryInstances.registry_info(registry[uuid]).version_info))
  end
end

function registryinstance_from_registryname(
  registryname::String; registries=RegistryInstances.reachable_registries()
)
  which_registries = findall(registries) do registry
    return registry.name == registryname
  end
  return registries[only(which_registries)]
end

# Get the dependencies and weak dependencies of a package.
function dependencies(
  pkgname::String; weakdeps=true, registries=RegistryInstances.reachable_registries()
)
  uuid = uuid_from_pkgname(pkgname; registries)
  registry = registryinstance_from_pkgname(pkgname; registries)
  pkginfo = RegistryInstances.registry_info(registry[uuid])
  latest_version = maximum(keys(pkginfo.version_info))
  # Use pkginfo.compat since it generally includes Deps and WeakDeps,
  # pkginfo.deps doesn't include WeakDeps.
  deps = String[]
  for (k, v) in pairs(pkginfo.compat)
    if latest_version ∈ k
      append!(deps, collect(keys(v)))
    end
  end
  return deps
end

to_registry(registry::RegistryInstances.RegistryInstance) = registry
to_registry(registryname::String) = registryinstance_from_registryname(registryname)

function dependents(
  pkgname::String; registries=RegistryInstances.reachable_registries(), weakdeps=true
)
  registries = to_registry.(registries)
  deps = String[]
  for registry in registries
    for (_, pkgentry′) in registry
      pkgname′ = pkgentry′.name
      if pkgname ∈ dependencies(pkgname′; weakdeps, registries)
        push!(deps, pkgname′)
      end
    end
  end
  return deps
end

end
