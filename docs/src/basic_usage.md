```@meta
CurrentModule = Magika
```
# Basic Usage

This guide covers the fundamental ways to use Magika.jl for file type detection.

## Initialization

First, create a Magika detector configuration:

```julia
using Magika

# Create a detector with default settings (high confidence mode)
m = MagikaConfig()
```

## File Detection Methods

Magika.jl provides three primary methods for detecting file types:

### 1. From File Path

```julia
result = identify_path(m, "document.pdf")
```

### 2. From Byte Content

```julia
content = read("image.png")
result = identify_bytes(m, content)
```

### 3. From IO Stream

```julia
open("data.csv", "r") do io
    result = identify_stream(m, io)
end
```

## Handling Results

Always check if the identification was successful before accessing prediction details:

```julia
if is_ok(result)
    println("File type: $(result.prediction.output.description)")
    println("MIME type: $(result.prediction.output.mime_type)")
    println("Confidence score: $(result.prediction.score)")
else
    println("Error identifying file: $(result.status)")
end
```

## Prediction Modes

Magika.jl offers different confidence thresholds for predictions:

```julia
# High confidence mode (default) - only returns high-confidence predictions
m = MagikaConfig(prediction_mode=HIGH_CONFIDENCE)

# Medium confidence mode - balanced approach
m = MagikaConfig(prediction_mode=MEDIUM_CONFIDENCE)

# Best guess mode - always returns a prediction
m = MagikaConfig(prediction_mode=BEST_GUESS)
```

## Example Workflow

Here's a complete example showing common usage patterns:

```julia
using Magika

# Initialize detector
m = MagikaConfig()

# Identify a file
result = identify_path(m, "example.py")

if is_ok(result)
    println("File path: $(result.path)")
    println("Content type: $(result.prediction.output.description)")
    println("MIME type: $(result.prediction.output.mime_type)")
    println("File group: $(result.prediction.output.group)")
    println("Extensions: $(join(result.prediction.output.extensions, \", \"))")
    println("Confidence: $(result.prediction.score)")
    
    # Check if this was a raw prediction or overwritten
    if result.prediction.overwrite_reason != NONE
        println("Original prediction was overwritten because: $(result.prediction.overwrite_reason)")
    end
else
    println("Failed to identify file: $(result.status)")
end
```

By understanding these basic usage patterns, you can effectively integrate Magika.jl into your Julia applications for accurate file type detection.
