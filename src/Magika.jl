module Magika


include("get_model_files.jl")
include("types.jl")
include("model.jl")

export MagikaConfig, identify_bytes, identify_path, identify_stream
export PredictionMode,HIGH_CONFIDENCE,MEDIUM_CONFIDENCE,BEST_GUESS
export ContentTypeLabel, MagikaResult, is_ok,Status,OverwriteReason


export NONE ,LOW_CONFIDENCE,OVERWRITE_MAP ,OK ,FILE_NOT_FOUND_ERROR ,PERMISSION_ERROR,UNKNOWN_ERROR


end 

