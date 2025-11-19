
using LazyArtifacts
using ONNXRunTime
using JSON3

"""
    MagikaConfig(; prediction_mode=HIGH_CONFIDENCE, no_dereference=false)

Create a Magika configuration object for file type detection.

# Arguments
- `prediction_mode::PredictionMode`: Confidence threshold mode for predictions.
    - `HIGH_CONFIDENCE`: Only returns predictions with high confidence specific to each content type
    - `MEDIUM_CONFIDENCE`: Balanced approach using a medium confidence threshold
    - `BEST_GUESS`: Always returns the most likely prediction regardless of confidence
- `no_dereference::Bool`: When true, symbolic links are identified as links rather than their targets

# Examples
```julia
# Create a detector with default settings
m = MagikaConfig()

# Create a detector that doesn't follow symlinks and uses medium confidence
m = MagikaConfig(prediction_mode=MEDIUM_CONFIDENCE, no_dereference=true)
```
"""
mutable struct MagikaConfig
    _model_config::ModelConfig
    _cts_infos::Dict{ContentTypeLabel, ContentTypeInfo}
    _onnx_session::InferenceSession
    _target_labels_space_map::Dict{Int, ContentTypeLabel}
    
    prediction_mode::PredictionMode
    no_dereference::Bool

    function MagikaConfig(;
        prediction_mode::PredictionMode = HIGH_CONFIDENCE,
        no_dereference::Bool = false,
    )

        kb_path = joinpath(LazyArtifacts.artifact"magika_artifact","content_types_kb.min.json")
        _cts_infos = _load_content_types_kb(kb_path)
        
        config_path = joinpath(LazyArtifacts.artifact"magika_artifact", "config.min.json")
        _model_config = _load_model_config(config_path)

        model_path = joinpath(LazyArtifacts.artifact"magika_artifact", "model.onnx")
        _onnx_session = ONNXRunTime.load_inference(model_path)
        
        _target_labels_space_map = Dict(
            (i-1) => label for (i, label) in enumerate(_model_config.target_labels_space)
        )

        new(
            _model_config, _cts_infos, _onnx_session, _target_labels_space_map,
            prediction_mode, no_dereference
        )
    end
end

function _load_model_config(path::String)::ModelConfig

        json_data = JSON3.read(read(path, String))
    ModelConfig(
        json_data.beg_size,
        json_data.mid_size,
        json_data.end_size,
        json_data.use_inputs_at_offsets,
        json_data.medium_confidence_threshold,
        json_data.min_file_size_for_dl,
        json_data.padding_token,
        json_data.block_size,
        [ContentTypeLabel(s) for s in json_data.target_labels_space],
        Dict(ContentTypeLabel(k) => v for (k, v) in json_data.thresholds),
        Dict(ContentTypeLabel(k) => ContentTypeLabel(v) for (k, v) in json_data.overwrite_map)
    )
end

function _load_content_types_kb(path::String)::Dict{ContentTypeLabel, ContentTypeInfo}
    json_data = JSON3.read(read(path, String))

    kb = Dict{ContentTypeLabel, ContentTypeInfo}()
    for (label_str, info) in json_data
        label = ContentTypeLabel(String(label_str))
        kb[label] = ContentTypeInfo(
            label,
            isnothing(info.mime_type) ? (info.is_text ? "text/plain" : "application/octet-stream") : info.mime_type,
            isnothing(info.group) ? "unknown" : info.group,
            isnothing(info.description) ? string(label) : info.description,
            String[ext for ext in info.extensions],
            info.is_text
        )
    end
    kb[UNDEFINED] = ContentTypeInfo(UNDEFINED, "application/undefined", "undefined", "Undefined", String[], false)
    return kb
end
"""
    identify_path(m::MagikaConfig, path::AbstractString)::MagikaResult

Identify the content type of a file at the given path.

# Arguments
- `m::MagikaConfig`: Pre-configured Magika detector
- `path::AbstractString`: Path to the file to analyze

# Returns
A `MagikaResult` object containing the detection results. Check with `is_ok(result)` before accessing prediction details.

# Examples
```julia
m = MagikaConfig()
result = identify_path(m, "document.pdf")
if is_ok(result)
    println("Detected as: ", result.prediction.output.description)
    println("MIME type: ", result.prediction.output.mime_type)
    println("Confidence: ", result.prediction.score)
else
    println("Error: ", result.status)
end
```
"""
identify_path(m::MagikaConfig, path::String) = _get_result_from_path(m, path)

"""
    identify_bytes(m::MagikaConfig, content::Vector{UInt8})::MagikaResult

Identify the content type from raw byte content.

# Arguments
- `m::MagikaConfig`: Pre-configured Magika detector
- `content::Vector{UInt8}`: Byte array containing file content to analyze

# Returns
A `MagikaResult` object containing the detection results.

# Examples
```julia
m = MagikaConfig()
content = read("image.png")
result = identify_bytes(m, content)
println("Content type: ", result.prediction.output.label)
```
"""
identify_bytes(m::MagikaConfig, content::Vector{UInt8}) = _get_result_from_bytes(m, content)

"""
    identify_stream(m::MagikaConfig, stream::IO)::MagikaResult

Identify the content type from an IO stream.

# Arguments
- `m::MagikaConfig`: Pre-configured Magika detector
- `stream::IO`: IO stream to read content from (will be seeked)

# Returns
A `MagikaResult` object containing the detection results.

# Examples
```julia
m = MagikaConfig()
open("data.csv", "r") do io
    result = identify_stream(m, io)
    println("File group: ", result.prediction.output.group)
end
```
"""
identify_stream(m::MagikaConfig, stream::IO) = _get_result_from_stream(m, stream)


function _get_result_from_path(m::MagikaConfig, path::String)::MagikaResult
    if m.no_dereference && islink(path)
        return _result_from_labels(m, path, UNDEFINED, SYMLINK, 1.0f0)
    end
    if !ispath(path)
        return MagikaResult(path, FILE_NOT_FOUND_ERROR)
    end
    if isdir(path)
        return _result_from_labels(m, path, UNDEFINED, DIRECTORY, 1.0f0)
    end
    try
        open(path, "r") do io
            return _get_result_from_stream(m, io; path=path)
        end
    catch e
        isa(e, SystemError) && e.errnum == 13 && return MagikaResult(path, PERMISSION_ERROR)
        rethrow(e)
    end
end

_get_result_from_bytes(m::MagikaConfig, content::Vector{UInt8}) = _get_result_from_stream(m, IOBuffer(content); path="-")

function _get_result_from_stream(m::MagikaConfig, stream::IO; path::String="-")::MagikaResult
    file_size = try nb_available(stream) catch; Int(filesize(stream)) end
    if file_size == 0
        return _result_from_labels(m, path, UNDEFINED, EMPTY, 1.0f0)
    end
    cfg = m._model_config
    if file_size < cfg.min_file_size_for_dl
        seekstart(stream)
        return _get_result_from_few_bytes(m, read(stream, file_size), path)
    end
    features = _extract_features(stream, cfg, file_size)
    if features.beg[cfg.min_file_size_for_dl] == cfg.padding_token
        seekstart(stream)
        return _get_result_from_few_bytes(m, read(stream, min(file_size, cfg.block_size)), path)
    end
    return _get_result_from_features(m, features, path)
end

function _extract_features(stream::IO, cfg::ModelConfig, file_size::Integer)
    bytes_to_read = min(cfg.block_size, file_size)
    seekstart(stream)
    beg_content = read(stream, bytes_to_read)
    start_idx = findfirst(c -> !isspace(Char(c)), beg_content)
    stripped_beg = isnothing(start_idx) ? "" : @view beg_content[start_idx:end]
    beg_ints = Vector{Int}(undef, cfg.beg_size)
    len_beg = length(stripped_beg)
    copyto!(beg_ints, 1, stripped_beg, 1, min(len_beg, cfg.beg_size))
    len_beg < cfg.beg_size && (beg_ints[(len_beg+1):end] .= cfg.padding_token)
    seek(stream, file_size - bytes_to_read)
    end_content = read(stream, bytes_to_read)
    end_idx = findlast(c -> !isspace(Char(c)), end_content)
    stripped_end = isnothing(end_idx) ? "" : @view end_content[1:end_idx]
    end_ints = Vector{Int}(undef, cfg.end_size)
    len_end = length(stripped_end)
    if len_end < cfg.end_size
        end_ints[1:(cfg.end_size - len_end)] .= cfg.padding_token
        copyto!(end_ints, cfg.end_size - len_end + 1, stripped_end, 1, len_end)
    else
        copyto!(end_ints, 1, stripped_end,1, cfg.end_size)
    end
    return (beg = beg_ints, fin = end_ints)
end

function _get_result_from_features(m::MagikaConfig, features, path::String)::MagikaResult
    feature_vector = vcat(features.beg, features.fin)
    input_tensor = Int32.(reshape(feature_vector, 1, :))
onnx_result = m._onnx_session((; bytes = input_tensor))

    scores = vec(onnx_result.target_label) 
    max_score, max_idx = findmax(scores)
    dl_label = m._target_labels_space_map[max_idx - 1]
    output_label, overwrite_reason = _get_output_label_from_dl(m, dl_label, Float32(max_score))
    return _result_from_labels(m, path, dl_label, output_label, Float32(max_score), overwrite_reason)
end

function _get_output_label_from_dl(m::MagikaConfig, dl_label::ContentTypeLabel, score::Float32)
    cfg = m._model_config
    output_label = get(cfg.overwrite_map, dl_label, dl_label)
    overwrite_reason = (output_label != dl_label) ? OVERWRITE_MAP : NONE
    threshold = get(cfg.thresholds, dl_label, cfg.medium_confidence_threshold)
    is_confident = (m.prediction_mode == BEST_GUESS) ||
                   (m.prediction_mode == MEDIUM_CONFIDENCE && score >= cfg.medium_confidence_threshold) ||
                   (m.prediction_mode == HIGH_CONFIDENCE && score >= threshold)
    if !is_confident
        new_output_label = m._cts_infos[output_label].is_text ? TXT : UNKNOWN
        if new_output_label != output_label
            output_label = new_output_label
            overwrite_reason = LOW_CONFIDENCE
        elseif overwrite_reason != OVERWRITE_MAP
            overwrite_reason = NONE
        end
    end
    return output_label, overwrite_reason
end

function _get_result_from_few_bytes(m::MagikaConfig, content::Vector{UInt8}, path::String)
    label = isvalid(String, content) ? TXT : UNKNOWN
    return _result_from_labels(m, path, UNDEFINED, label, 1.0f0)
end

function _result_from_labels(m::MagikaConfig, path, dl_label, output_label, score, reason=NONE)
    prediction = MagikaPrediction(
        m._cts_infos[dl_label],
        m._cts_infos[output_label],
        score,
        reason
    )
    return MagikaResult(string(path), OK; prediction)
end