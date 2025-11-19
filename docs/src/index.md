```@meta
CurrentModule = Magika
```
# Magika.jl

**AI-powered file type detection library for Julia**

## Overview

Magika.jl is a Julia implementation of [Google's Magika](https://github.com/google/magika), a state-of-the-art file type detection tool that leverages deep learning to accurately identify file content types. This package brings the powerful file identification capabilities of Magika to the Julia ecosystem.

Magika.jl can identify hundreds of different file types with high accuracy, even when file extensions are missing or incorrect. It uses a pre-trained deep learning model (only a few MBs in size) that can process files in milliseconds on standard hardware.

*This package was developed with assistance from multiple AI tools to accelerate implementation and ensure compatibility with the original Magika project.*

## Installation

```julia
using Pkg
Pkg.add("Magika")
```

## Quick Start

```julia
using Magika

# Initialize the detector with default settings
m = MagikaConfig()

# Identify a file by path
result = identify_path(m, "path/to/file.txt")
println("File type: $(result.prediction.output.description)")

# Identify bytes directly
content = read("path/to/file.txt")
result = identify_bytes(m, content)
println("MIME type: $(result.prediction.output.mime_type)")

# Identify from an IO stream
open("path/to/file.txt", "r") do io
    result = identify_stream(m, io)
    println("Content label: $(result.prediction.output.label)")
end
```

## Core Functionality

### Prediction Modes

Magika supports different confidence thresholds for predictions:

```julia
# Create a conservative detector (only high-confidence predictions)
m = MagikaConfig(prediction_mode=HIGH_CONFIDENCE)

# Create a balanced detector (medium confidence threshold)
m = MagikaConfig(prediction_mode=MEDIUM_CONFIDENCE)

# Create a detector that always returns a prediction
m = MagikaConfig(prediction_mode=BEST_GUESS)
```

### Handling Results

```julia
result = identify_path(m, "document.pdf")

if is_ok(result)
    println("Status: OK")
    println("Content type: $(result.prediction.output.description)")
    println("MIME type: $(result.prediction.output.mime_type)")
    println("Confidence score: $(result.prediction.score)")
    println("File group: $(result.prediction.output.group)")
    println("Extensions: $(join(result.prediction.output.extensions, ", "))")
else
    println("Error identifying file: $(result.status)")
end
```

## Supported File Types

Magika.jl can identify over 300 different file types, including:

- Common document formats (PDF, DOCX, TXT)
- Programming languages (Python, C++, JavaScript)
- Image formats (PNG, JPEG, GIF, WebP)
- Audio/Video formats (MP3, MP4, WebM)
- Archive formats (ZIP, TAR, GZIP)
- System files (ELF, PE binaries)
- And many more specialized formats

## Advanced Usage

### Symbolic Links Handling

```julia
# Create a configuration that doesn't follow symbolic links
m = MagikaConfig(no_dereference=true)
result = identify_path(m, "symlink-to-file")
# Will identify as a symlink instead of the target file type
```
