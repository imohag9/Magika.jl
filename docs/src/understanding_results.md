```@meta
CurrentModule = Magika
```
# Understanding Results

This guide explains the structure of Magika.jl results and how to interpret them effectively.

## Result Structure Overview

A `MagikaResult` contains three main components:

1. **Path information**: The file path or identifier that was analyzed
2. **Status**: Whether the identification was successful
3. **Prediction details** (if successful): Comprehensive information about the detected content type

## Checking Result Status

Always check the status before accessing prediction details:

```julia
result = identify_path(m, "file.txt")

if is_ok(result)
    # Safe to access prediction details
    println("Detection successful!")
else
    println("Detection failed with status: $(result.status)")
end
```

## Status Types

Magika.jl defines several status codes:

- `OK`: Detection was successful
- `FILE_NOT_FOUND_ERROR`: The file path doesn't exist
- `PERMISSION_ERROR`: Unable to access the file due to permissions
- `UNKNOWN_ERROR`: An unexpected error occurred

## Prediction Details

When status is `OK`, the `result.prediction` field contains:

### 1. Deep Learning Output (`dl`)

The raw prediction from the neural network model:
- `label`: The content type label (e.g., `python`, `jpeg`)
- `description`: Human-readable description (e.g., "Python source")
- `mime_type`: Standard MIME type (e.g., "text/x-python")
- `group`: Content category (e.g., "code", "document", "image")
- `extensions`: Common file extensions for this type
- `is_text`: Whether this is a text-based format

### 2. Final Output (`output`)

The final content type after applying confidence thresholds and overwrite rules:
- Same fields as `dl`, but potentially modified based on confidence

### 3. Confidence Score

- `score`: A float between 0.0 and 1.0 indicating prediction confidence
- Higher scores indicate more reliable predictions

### 4. Overwrite Reason

Explains why the final output might differ from the raw model prediction:
- `NONE`: No overwrite occurred
- `LOW_CONFIDENCE`: Downgraded due to low confidence score
- `OVERWRITE_MAP`: Changed according to predefined mapping rules

## Example: Complete Result Analysis

```julia
function analyze_result(result::MagikaResult)
    println("Path: $(result.path)")
    
    if !is_ok(result)
        println("Status: $(result.status)")
        return
    end
    
    pred = result.prediction
    
    println("\nRaw model prediction (dl):")
    println("  Label: $(pred.dl.label)")
    println("  Description: $(pred.dl.description)")
    println("  MIME type: $(pred.dl.mime_type)")
    println("  Group: $(pred.dl.group)")
    println("  Extensions: $(join(pred.dl.extensions, \", \"))")
    println("  Is text: $(pred.dl.is_text)")
    
    println("\nFinal output:")
    println("  Label: $(pred.output.label)")
    println("  Description: $(pred.output.description)")
    
    println("\nConfidence score: $(pred.score)")
    
    println("\nOverwrite reason: $(pred.overwrite_reason)")
    if pred.overwrite_reason != NONE
        println("  Note: The raw prediction was modified because of low confidence")
        println("  or predefined mapping rules. Consider the confidence score")
        println("  when making decisions based on this result.")
    end
    
    # Practical interpretation
    if pred.score > 0.95
        println("\nInterpretation: Very high confidence prediction")
    elseif pred.score > 0.85
        println("\nInterpretation: High confidence prediction")
    elseif pred.score > 0.7
        println("\nInterpretation: Medium confidence - generally reliable")
    else
        println("\nInterpretation: Low confidence - consider verification")
    end
    
    # Security considerations
    if pred.overwrite_reason == LOW_CONFIDENCE && pred.output.is_text
        println("\nSecurity note: This was originally detected as binary content")
        println("but downgraded to generic text due to low confidence.")
        println("Exercise caution when processing this file.")
    end
end

# Usage example
result = identify_path(MagikaConfig(), "unknown_file")
analyze_result(result)
```

## Common Result Patterns

### 1. High-Confidence Detection
```julia
# Raw prediction and final output are the same
# High confidence score (>0.9)
# Overwrite reason is NONE
```

### 2. Low-Confidence Text File
```julia
# Raw prediction might be "python" but final output is "txt"
# Confidence score is medium (0.6-0.8)
# Overwrite reason is LOW_CONFIDENCE
```

### 3. Low-Confidence Binary File
```julia
# Raw prediction might be "pebin" but final output is "unknown"
# Confidence score is low (<0.6)
# Overwrite reason is LOW_CONFIDENCE
```

### 4. Mapping Override
```julia
# Raw prediction might be "windows_dll" but final output is "dll"
# Overwrite reason is OVERWRITE_MAP
# This happens due to predefined content type mappings
```

Understanding these patterns helps you make informed decisions about how to handle different file types in your applications while maintaining appropriate security postures.