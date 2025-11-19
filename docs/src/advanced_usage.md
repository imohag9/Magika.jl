```@meta
CurrentModule = Magika
```
# Advanced Usage

This guide covers advanced features and configuration options for Magika.jl.

## Symbolic Link Handling

By default, Magika follows symbolic links to identify the target file type. You can change this behavior:

```julia
# Create a detector that doesn't follow symbolic links
m = MagikaConfig(no_dereference=true)

# This will identify as a symlink rather than following to the target
result = identify_path(m, "my_symlink")
```

## Batch Processing

Magika is optimized for processing multiple files efficiently:

```julia
function batch_identify(paths::Vector{String})
    m = MagikaConfig()
    results = Dict{String, MagikaResult}()
    
    for path in paths
        results[path] = identify_path(m, path)
    end
    
    return results
end

# Example usage
files = ["file1.txt", "image.jpg", "document.pdf"]
results = batch_identify(files)

for (path, result) in results
    if is_ok(result)
        println("$path: $(result.prediction.output.description)")
    else
        println("$path: Error - $(result.status)")
    end
end
```

## Custom Confidence Thresholds

While Magika uses built-in thresholds for each content type, you can implement custom filtering:

```julia
function identify_with_custom_threshold(m::MagikaConfig, path::String, min_score::Float32=0.8f0)
    result = identify_path(m, path)
    
    if is_ok(result) && result.prediction.score >= min_score
        return result
    else
        # Return a generic result for low confidence predictions
        generic_result = MagikaResult(
            path,
            OK,
            MagikaPrediction(
                m._cts_infos[UNDEFINED],
                m._cts_infos[result.prediction.output.is_text ? TXT : UNKNOWN],
                result.prediction.score,
                LOW_CONFIDENCE
            )
        )
        return generic_result
    end
end
```

## Integration with File Processing Pipelines

Here's an example of integrating Magika with a file processing pipeline:

```julia
function process_file_by_type(path::String)
    m = MagikaConfig()
    result = identify_path(m, path)
    
    if !is_ok(result)
        error("Could not identify file type: $(result.status)")
    end
    
    content_type = result.prediction.output.label
    
    try
        # Process based on detected content type
        if content_type == ContentTypeLabel("json")
            println("Processing as JSON file")
            data = JSON3.read(read(path, String))
            # Process JSON data...
            
        elseif content_type == ContentTypeLabel("csv")
            println("Processing as CSV file")
            df = CSV.read(path, DataFrame)
            # Process CSV data...
            
        elseif content_type == ContentTypeLabel("png") || content_type == ContentTypeLabel("jpeg")
            println("Processing as image file")
            img = load(path)
            # Process image data...
            
        else
            println("Generic processing for $(result.prediction.output.description)")
            content = read(path, String)
            # Generic processing...
        end
        
    catch e
        # Fallback if content type detection was incorrect
        println("Error during processing: $e")
        println("Attempting generic processing...")
        content = read(path, String)
        # Generic processing fallback...
    end
end
```

## Performance Optimization

For high-throughput applications, reuse the same MagikaConfig instance:

```julia
function high_throughput_processor(file_paths::Vector{String})
    # Create ONE detector instance for all files
    m = MagikaConfig(prediction_mode=MEDIUM_CONFIDENCE)
    
    results = []
    for path in file_paths
        push!(results, identify_path(m, path))
    end
    
    return results
end
```

## Handling Edge Cases

```julia
function robust_file_identifier(path::String)
    m = MagikaConfig()
    
    # Handle non-existent files
    if !ispath(path)
        return MagikaResult(path, FILE_NOT_FOUND_ERROR)
    end
    
    # Handle permission issues with try-catch
    try
        return identify_path(m, path)
    catch e
        if isa(e, SystemError) && e.errnum == 13
            return MagikaResult(path, PERMISSION_ERROR)
        end
        rethrow(e)
    end
end
```

These advanced patterns demonstrate how to use Magika.jl in production environments with robust error handling and performance considerations.
