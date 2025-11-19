# Magika 
 [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://imohag9.github.io/Magika.jl/dev/) [![Build Status](https://github.com/imohag9/Magika.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/imohag9/Magika.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

**AI-powered file type detection library for Julia**

## Overview

Magika.jl is a Julia implementation of [Google's Magika](https://github.com/google/magika), a state-of-the-art file type detection tool that leverages deep learning to accurately identify file content types. This package brings the powerful file identification capabilities of Magika to the Julia ecosystem with a native interface and optimized performance.

Magika.jl can identify hundreds of different file types with high accuracy, even when file extensions are missing or incorrect. It uses a pre-trained deep learning model (only a few MBs in size) that can process files in milliseconds on standard hardware.


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

## Features

- **High Accuracy**: Identifies over 200+ file types with ~99% accuracy
- **Fast**: Processes files in milliseconds after model loading
- **Size Independent**: Processing time is nearly constant regardless of file size
- **Multiple Prediction Modes**:
  - `HIGH_CONFIDENCE`: Only returns predictions above content-specific thresholds
  - `MEDIUM_CONFIDENCE`: Balanced approach for most use cases
  - `BEST_GUESS`: Always returns the most likely prediction
- **Comprehensive Output**: Provides detailed information including:
  - Content type label and description
  - MIME type
  - File group classification
  - Confidence score
  - Common file extensions
- **Symlink Handling**: Option to detect symlinks without following them
- **Low-memory Footprint**: Only reads beginning and end of files for analysis

## Configuration Options

```julia
# Create a configuration with specific settings
m = MagikaConfig(
    prediction_mode=HIGH_CONFIDENCE,  # or MEDIUM_CONFIDENCE, BEST_GUESS
    no_dereference=true               # Don't follow symlinks
)
```

## Result Structure

Results are returned as `MagikaResult` objects containing:

- `path`: The file path analyzed
- `status`: Operation status : OK, FILE_NOT_FOUND_ERROR, etc.
- `prediction`: Detailed prediction information when status is OK
  - `dl`: The deep learning model's raw prediction
  - `output`: The final output label after applying rules
  - `score`: Confidence score (0.0-1.0)
  - `overwrite_reason`: Why the label was changed from raw prediction (if applicable)

## Advanced Usage

```julia
# Check if identification was successful
if is_ok(result)
    println("Detected as: $(result.prediction.output.description)")
    println("Confidence score: $(result.prediction.score)")
    println("MIME type: $(result.prediction.output.mime_type)")
    println("Possible extensions: $(join(result.prediction.output.extensions, ", "))")
else
    println("Error identifying file: $(result.status)")
end
```

## Development Notes

This package was developed with the assistance of multiple AI coding tools to accelerate implementation and ensure compatibility with the original Google Magika project. These tools helped with:
- Code translation from the original Python/Rust implementations
- API design consistency
- Error handling patterns
- Documentation generation
- Test case development

The core functionality remains faithful to the original Magika project, and all model files are downloaded directly from Google's repository to ensure consistent behavior.

## Acknowledgements

- This package is based on [Google's Magika](https://github.com/google/magika) project
- Special thanks to the Magika team at Google for their research and open-sourcing this technology
- The ONNXRunTime.jl team for providing Julia bindings to ONNX Runtime

## License

MIT License 

This project is not affiliated with, endorsed by, or connected to Google LLC. "Magika" is a trademark of Google LLC. This implementation is an independent, open-source adaptation.