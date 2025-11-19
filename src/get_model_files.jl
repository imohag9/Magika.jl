using Pkg.Artifacts
using Downloads 

function get_files()

    artifact_name = "magika_artifact"
    artifacts_toml = joinpath(dirname(@__DIR__), "Artifacts.toml")
    hash = artifact_hash(artifact_name, artifacts_toml)
    if !isnothing(hash) && artifact_exists(hash)
        # Artifact magika_artifact already exists and is valid.
        return
    end
    hash = create_artifact() do artifact_dir
        println("Downloading files to $artifact_dir...")

        files_to_download = [
            ("https://raw.githubusercontent.com/google/magika/refs/heads/main/python/src/magika/models/standard_v3_3/config.min.json", "config.min.json"),
            ("https://github.com/google/magika/raw/refs/heads/main/python/src/magika/models/standard_v3_3/model.onnx", "model.onnx"),
            ("https://github.com/google/magika/raw/refs/heads/main/python/src/magika/config/content_types_kb.min.json", "content_types_kb.min.json")
        ]

        for (url, filename) in files_to_download
            local_path = joinpath(artifact_dir, filename)
            println("Downloading $url to $local_path...")
            try
                Downloads.download(url, local_path)
            catch e
                println("Error downloading $url: $e")
                return
            end
        end
    end

    bind_artifact!(
        artifacts_toml,
        artifact_name,
        hash,
        force = true
    )
end

get_files()