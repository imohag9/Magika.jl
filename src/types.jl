"""
    @enum PredictionMode HIGH_CONFIDENCE MEDIUM_CONFIDENCE BEST_GUESS

Enumeration of prediction confidence modes that control how strictly Magika applies confidence thresholds.

# Values
- `HIGH_CONFIDENCE`: Most conservative mode. Only returns predictions that meet content-type-specific high confidence thresholds.
- `MEDIUM_CONFIDENCE`: Balanced mode. Uses a medium confidence threshold for all content types.
- `BEST_GUESS`: Most permissive mode. Always returns the model's top prediction regardless of confidence score.

# Examples
```julia
# Create a highly conservative detector
m = MagikaConfig(prediction_mode=HIGH_CONFIDENCE)
```
"""
@enum PredictionMode::UInt8 begin
    HIGH_CONFIDENCE
    MEDIUM_CONFIDENCE
    BEST_GUESS
end

"""
    @enum OverwriteReason NONE LOW_CONFIDENCE OVERWRITE_MAP

Enumeration of reasons why a model prediction might be overwritten with a different label.

# Values
- `NONE`: No overwrite occurred, using the raw model prediction
- `LOW_CONFIDENCE`: Prediction was downgraded due to low confidence score
- `OVERWRITE_MAP`: Prediction was replaced according to predefined mapping rules

# Notes
This information is available in `result.prediction.overwrite_reason` to understand why a prediction might differ from the model's raw output.
"""
@enum OverwriteReason::UInt8 begin
    NONE
    LOW_CONFIDENCE
    OVERWRITE_MAP
end

"""
    @enum Status OK FILE_NOT_FOUND_ERROR PERMISSION_ERROR UNKNOWN_ERROR

Enumeration of possible status codes for identification operations.

# Values
- `OK`: Operation completed successfully
- `FILE_NOT_FOUND_ERROR`: File path does not exist
- `PERMISSION_ERROR`: Unable to access file due to permissions
- `UNKNOWN_ERROR`: Other unexpected error occurred
"""
@enum Status::UInt8 begin
    OK
    FILE_NOT_FOUND_ERROR
    PERMISSION_ERROR
    UNKNOWN_ERROR
end

# --- ContentTypeLabel Enum and Mappings ---

"""
    @enum ContentTypeLabel

Enumeration of all supported content type labels that Magika can detect. Contains over 300 labels for different file formats, from common types like PNG, PDF to specialized formats like BRAINFUCK, VIMRC.

# Examples
```julia
# Get the string representation of a content type
println(string(ContentTypeLabel("png")))  # "png"

# Convert from string to enum
label = ContentTypeLabel("jpeg")
```

# Notes
Each label corresponds to a specific file format with associated metadata including MIME type, description, and file extensions.
"""
@enum ContentTypeLabel begin
    _3DS
    _3DSM
    _3DSX
    _3GP
    _3MF
    ABNF
    ACE
    ADA
    AFF
    AI
    AIDL
    ALGOL68
    ANI
    APK
    APPLEBPLIST
    APPLEDOUBLE
    APPLEPLIST
    APPLESINGLE
    AR
    ARC
    ARJ
    ARROW
    ASC
    ASD
    ASF
    ASM
    ASP
    AU
    AUTOHOTKEY
    AUTOIT
    AVI
    AVIF
    AVRO
    AWK
    AX
    BATCH
    BAZEL
    BCAD
    BIB
    BMP
    BPG
    BPL
    BRAINFUCK
    BRF
    BZIP
    BZIP3
    C
    CAB
    CAD
    CAT
    CDF
    CHM
    CLOJURE
    CMAKE
    COBOL
    COFF
    COFFEESCRIPT
    COM
    CPL
    CPP
    CRT
    CRX
    CS
    CSPROJ
    CSS
    CSV
    CTL
    DART
    DEB
    DEX
    DEY
    DICOM
    DIFF
    DIRECTORY
    DJANGO
    DLL
    DM
    DMG
    DMIGD
    DMSCRIPT
    DOC
    DOCKERFILE
    DOCX
    DOSMBR
    DOTX
    DSSTORE
    DWG
    DXF
    DYLIB
    EBML
    ELF
    ELIXIR
    EMF
    EML
    EMPTY
    EPUB
    ERB
    ERLANG
    ESE
    EXE
    EXP
    FLAC
    FLUTTER
    FLV
    FORTRAN
    FPX
    GEMFILE
    GEMSPEC
    GIF
    GITATTRIBUTES
    GITMODULES
    GLEAM
    GO
    GPX
    GRADLE
    GROOVY
    GZIP
    H
    H5
    HANDLEBARS
    HASKELL
    HCL
    HEIF
    HFS
    HLP
    HPP
    HTA
    HTACCESS
    HTML
    HVE
    HWP
    ICC
    ICNS
    ICO
    ICS
    IGNOREFILE
    IMG
    INI
    INTERNETSHORTCUT
    IOSAPP
    IPYNB
    ISO
    JAR
    JAVA
    JAVABYTECODE
    JAVASCRIPT
    JINJA
    JNG
    JNLP
    JP2
    JPEG
    JSON
    JSONC
    JSONL
    JSX
    JULIA
    JXL
    KO
    KOTLIN
    KS
    LATEX
    LATEXAUX
    LESS
    LHA
    LICENSE
    LISP
    LITCS
    LNK
    LOCK
    LRZ
    LUA
    LZ
    LZ4
    LZX
    M3U
    M4
    MACHO
    MAFF
    MAKEFILE
    MARKDOWN
    MATLAB
    MHT
    MIDI
    MKV
    MP2
    MP3
    MP4
    MPEGTS
    MSCOMPRESS
    MSI
    MSIX
    MST
    MUI
    MUM
    MUN
    NIM
    NPY
    NPZ
    NULL
    NUPKG
    OBJECT
    OBJECTIVEC
    OCAML
    OCX
    ODEX
    ODIN
    ODP
    ODS
    ODT
    OGG
    OLE
    ONE
    ONNX
    OOXML
    OTF
    OUTLOOK
    PALMOS
    PARQUET
    PASCAL
    PBM
    PCAP
    PDB
    PDF
    PEBIN
    PEM
    PERL
    PGP
    PHP
    PICKLE
    PNG
    PO
    POSTSCRIPT
    POWERSHELL
    PPT
    PPTX
    PRINTFOX
    PROLOG
    PROTEINDB
    PROTO
    PROTOBUF
    PSD
    PUB
    PYTHON
    PYTHONBYTECODE
    PYTHONPAR
    PYTORCH
    QOI
    QT
    R
    RANDOMASCII
    RANDOMBYTES
    RANDOMTXT
    RAR
    RDF
    RDP
    RIFF
    RLIB
    RLL
    RPM
    RST
    RTF
    RUBY
    RUST
    RZIP
    SCALA
    SCHEME
    SCR
    SCRIPTWSF
    SCSS
    SEVENZIP
    SGML
    SH3D
    SHELL
    SMALI
    SNAP
    SO
    SOLIDITY
    SQL
    SQLITE
    SQUASHFS
    SRT
    STLBINARY
    STLTEXT
    SUM
    SVD
    SVG
    SWF
    SWIFT
    SYMLINK
    SYMLINKTEXT
    SYS
    TAR
    TCL
    TEXTPROTO
    TGA
    THUMBSDB
    TIFF
    TMDX
    TOML
    TORRENT
    TROFF
    TSV
    TSX
    TTF
    TWIG
    TXT
    TXTASCII
    TXTUTF16
    TXTUTF8
    TYPESCRIPT
    UDF
    UNDEFINED
    UNIXCOMPRESS
    UNKNOWN
    VBA
    VBE
    VCARD
    VCS
    VCXPROJ
    VERILOG
    VHD
    VHDL
    VISIO
    VTT
    VUE
    WAD
    WASM
    WAV
    WEBM
    WEBP
    WEBTEMPLATE
    WIM
    WINREGISTRY
    WMA
    WMF
    WMV
    WOFF
    WOFF2
    XAR
    XCF
    XLS
    XLSB
    XLSX
    XML
    XPI
    XSD
    XZ
    YAML
    YARA
    ZIG
    ZIP
    ZLIBSTREAM
    ZST
end

# This function builds the mappings between the integer enum and string labels.
# It is called once when the module is loaded.
function _build_label_maps()
    # Statically define the string for each enum instance in the same order as the enum definition.
    string_values = [
        "3ds", "3dsm", "3dsx", "3gp", "3mf", "abnf", "ace", "ada", "aff", "ai", "aidl",
        "algol68", "ani", "apk", "applebplist", "appledouble", "appleplist", "applesingle",
        "ar", "arc", "arj", "arrow", "asc", "asd", "asf", "asm", "asp", "au",
        "autohotkey", "autoit", "avi", "avif", "avro", "awk", "ax", "batch", "bazel",
        "bcad", "bib", "bmp", "bpg", "bpl", "brainfuck", "brf", "bzip", "bzip3", "c",
        "cab", "cad", "cat", "cdf", "chm", "clojure", "cmake", "cobol", "coff",
        "coffeescript", "com", "cpl", "cpp", "crt", "crx", "cs", "csproj", "css",
        "csv", "ctl", "dart", "deb", "dex", "dey", "dicom", "diff", "directory",
        "django", "dll", "dm", "dmg", "dmigd", "dmscript", "doc", "dockerfile",
        "docx", "dosmbr", "dotx", "dsstore", "dwg", "dxf", "dylib", "ebml", "elf",
        "elixir", "emf", "eml", "empty", "epub", "erb", "erlang", "ese", "exe",
        "exp", "flac", "flutter", "flv", "fortran", "fpx", "gemfile", "gemspec",
        "gif", "gitattributes", "gitmodules", "gleam", "go", "gpx", "gradle",
        "groovy", "gzip", "h", "h5", "handlebars", "haskell", "hcl", "heif", "hfs",
        "hlp", "hpp", "hta", "htaccess", "html", "hve", "hwp", "icc", "icns", "ico",
        "ics", "ignorefile", "img", "ini", "internetshortcut", "iosapp", "ipynb",
        "iso", "jar", "java", "javabytecode", "javascript", "jinja", "jng", "jnlp",
        "jp2", "jpeg", "json", "jsonc", "jsonl", "jsx", "julia", "jxl", "ko",
        "kotlin", "ks", "latex", "latexaux", "less", "lha", "license", "lisp",
        "litcs", "lnk", "lock", "lrz", "lua", "lz", "lz4", "lzx", "m3u", "m4",
        "macho", "maff", "makefile", "markdown", "matlab", "mht", "midi", "mkv",
        "mp2", "mp3", "mp4", "mpegts", "mscompress", "msi", "msix", "mst", "mui",
        "mum", "mun", "nim", "npy", "npz", "null", "nupkg", "object", "objectivec",
        "ocaml", "ocx", "odex", "odin", "odp", "ods", "odt", "ogg", "ole", "one",
        "onnx", "ooxml", "otf", "outlook", "palmos", "parquet", "pascal", "pbm",
        "pcap", "pdb", "pdf", "pebin", "pem", "perl", "pgp", "php", "pickle", "png",
        "po", "postscript", "powershell", "ppt", "pptx", "printfox", "prolog",
        "proteindb", "proto", "protobuf", "psd", "pub", "python", "pythonbytecode",
        "pythonpar", "pytorch", "qoi", "qt", "r", "randomascii", "randombytes",
        "randomtxt", "rar", "rdf", "rdp", "riff", "rlib", "rll", "rpm", "rst",
        "rtf", "ruby", "rust", "rzip", "scala", "scheme", "scr", "scriptwsf",
        "scss", "sevenzip", "sgml", "sh3d", "shell", "smali", "snap", "so",
        "solidity", "sql", "sqlite", "squashfs", "srt", "stlbinary", "stltext",
        "sum", "svd", "svg", "swf", "swift", "symlink", "symlinktext", "sys",
        "tar", "tcl", "textproto", "tga", "thumbsdb", "tiff", "tmdx", "toml",
        "torrent", "troff", "tsv", "tsx", "ttf", "twig", "txt", "txtascii",
        "txtutf16", "txtutf8", "typescript", "udf", "undefined", "unixcompress",
        "unknown", "vba", "vbe", "vcard", "vcs", "vcxproj", "verilog", "vhd",
        "vhdl", "visio", "vtt", "vue", "wad", "wasm", "wav", "webm", "webp",
        "webtemplate", "wim", "winregistry", "wma", "wmf", "wmv", "woff", "woff2",
        "xar", "xcf", "xls", "xlsb", "xlsx", "xml", "xpi", "xsd", "xz", "yaml",
        "yara", "zig", "zip", "zlibstream", "zst"
    ]

    enum_instances = instances(ContentTypeLabel)

    if length(string_values) != length(enum_instances)
        error("FATAL: Mismatch between ContentTypeLabel enum definition and its string values. Please check for missing or extra labels.")
    end

    # Create the forward and reverse lookup dictionaries.
    label_to_str = Dict(enum_instances[i] => string_values[i]
    for i in eachindex(enum_instances))
    str_to_label = Dict(string_values[i] => enum_instances[i]
    for i in eachindex(enum_instances))

    return label_to_str, str_to_label
end

# These constant mappings are created once when the module is loaded.
const LABEL_TO_STRING_MAP, STRING_TO_LABEL_MAP = _build_label_maps()

# Overload Base.string for easy printing and string conversion of the enum.
Base.string(label::ContentTypeLabel) = LABEL_TO_STRING_MAP[label]

# constructors to allow creating an enum instance from a string and a symbol.
ContentTypeLabel(s::AbstractString) = STRING_TO_LABEL_MAP[s]
ContentTypeLabel(s::Symbol) = ContentTypeLabel(string(s))

"""
    struct ContentTypeInfo

Metadata container for a specific content type that Magika can identify.

# Fields
- `label::ContentTypeLabel`: Enum identifier for the content type (e.g., `python`, `jpeg`)
- `mime_type::String`: Standard MIME type associated with this content type (e.g., "text/x-python", "image/jpeg")
- `group::String`: Category group of the content type (e.g., "code", "document", "image", "audio")
- `description::String`: Human-readable description of the content type (e.g., "Python source", "JPEG image")
- `extensions::Vector{String}`: Common file extensions associated with this content type (e.g., ["py", "pyi"])
- `is_text::Bool`: Flag indicating whether this content type is text-based (true) or binary (false)

# Notes
This struct is automatically populated from Google Magika's content type knowledge base during initialization. Users typically access this information through prediction results rather than constructing it directly.

Each content type in Magika's detection system has a corresponding `ContentTypeInfo` that provides comprehensive metadata about that file format.

# Example
```julia
m = MagikaConfig()
result = identify_path(m, "script.py")

if is_ok(result)
    info = result.prediction.output
    println("File format: \$(info.description)")
    println("MIME type: \$(info.mime_type)")
    println("Common extensions: \$(join(info.extensions, \", \"))")
    println("Category: \$(info.group)")
    println("Text-based: \$(info.is_text)")
end
```
"""
struct ContentTypeInfo
    label::ContentTypeLabel
    mime_type::String
    group::String
    description::String
    extensions::Vector{String}
    is_text::Bool
end

"""
    struct MagikaPrediction

Container for the prediction results from Magika's deep learning model.

# Fields
- `dl::ContentTypeInfo`: The raw prediction directly from the deep learning model, before applying confidence thresholds or overwrite rules
- `output::ContentTypeInfo`: The final prediction after applying confidence thresholds and overwrite rules
- `score::Float32`: Confidence score between 0.0 and 1.0 indicating how certain the model is about its prediction
- `overwrite_reason::OverwriteReason`: Enum explaining why the final output might differ from the raw model prediction:
  - `NONE`: No overwrite occurred, output matches raw prediction
  - `LOW_CONFIDENCE`: Prediction was downgraded due to low confidence score
  - `OVERWRITE_MAP`: Prediction was replaced according to predefined mapping rules

# Notes
The distinction between `dl` (deep learning raw output) and `output` (final decision) is crucial for understanding Magika's behavior. In some cases, especially with low-confidence predictions, Magika will "downgrade" specific predictions to more generic types (e.g., from a specific programming language to generic "text") for safety and reliability.

The confidence score should be considered when making security-critical decisions about file handling. Higher scores indicate more reliable predictions.

# Example
```julia
m = MagikaConfig()
result = identify_path(m, "unknown_file")

if is_ok(result)
    pred = result.prediction
    
    # Access final prediction
    println("Detected as: \$(pred.output.description)")
    println("Confidence: \$(pred.score)")
    
    # Check if prediction was modified from raw model output
    if pred.overwrite_reason != NONE
        println("Original prediction (\$(pred.dl.description)) was modified because: \$(pred.overwrite_reason)")
    end
    
    # Use confidence score to make decisions
    if pred.score > 0.9
        println("High confidence prediction - safe to process automatically")
    elseif pred.overwrite_reason == LOW_CONFIDENCE
        println("Low confidence prediction - consider human verification")
    end
end
```
"""
struct MagikaPrediction
    dl::ContentTypeInfo
    output::ContentTypeInfo
    score::Float32
    overwrite_reason::OverwriteReason
end

"""
    struct MagikaResult

Container for file identification results.

# Fields
- `path::String`: Path or identifier of the analyzed content
- `status::Status`: Status of the identification operation (`OK`, `FILE_NOT_FOUND_ERROR`, etc.)
- `prediction::Union{MagikaPrediction, Nothing}`: Prediction details when status is `OK`

# Accessors
- Use `is_ok(result)` to check if identification was successful
- When successful, access prediction details via `result.prediction`
"""
struct MagikaResult
    path::String
    status::Status
    prediction::Union{MagikaPrediction, Nothing}

    MagikaResult(path, status; prediction = nothing) = new(path, status, prediction)
end

"""
    is_ok(result::MagikaResult)::Bool

Check if a MagikaResult represents a successful identification.

# Returns
`true` if the status is `OK`, `false` otherwise.

# Examples
```julia
result = identify_path(m, "file.txt")
if is_ok(result)
    # Safe to access result.prediction
    println("Detected as: ", result.prediction.output.description)
else
    println("Identification failed with status: ", result.status)
end
```
"""
is_ok(r::MagikaResult) = r.status == OK

"""
    struct ModelConfig

Configuration parameters for the Magika deep learning model. This struct contains all the hyperparameters and settings needed for feature extraction and prediction.

# Fields
- `beg_size::Int`: Number of bytes to extract from the beginning of a file for feature extraction.
- `mid_size::Int`: Number of bytes to extract from the middle of a file (currently not used in inference).
- `end_size::Int`: Number of bytes to extract from the end of a file for feature extraction.
- `use_inputs_at_offsets::Bool`: Flag indicating whether to use content at specific byte offsets (reserved for future use).
- `medium_confidence_threshold::Float32`: Default confidence threshold used in `MEDIUM_CONFIDENCE` prediction mode.
- `min_file_size_for_dl::Int`: Minimum file size (in bytes) required to use the deep learning model. Smaller files use simpler detection methods.
- `padding_token::Int`: Byte value used for padding when file content is shorter than required feature size.
- `block_size::Int`: Size of data blocks read from files during feature extraction.
- `target_labels_space::Vector{ContentTypeLabel}`: Vector of all possible content type labels the model can predict.
- `thresholds::Dict{ContentTypeLabel, Float32}`: Content type-specific confidence thresholds used in `HIGH_CONFIDENCE` mode.
- `overwrite_map::Dict{ContentTypeLabel, ContentTypeLabel}`: Mapping of content types to be automatically overwritten with alternative labels (e.g., for security reasons).

# Notes
This configuration is automatically loaded from the model's config file when a `MagikaConfig` is initialized. Users typically don't need to construct this struct directly.

The configuration values are optimized during model training to achieve high accuracy while maintaining fast inference times. The model only analyzes the beginning and end portions of files, making detection time nearly constant regardless of file size.

# Example
```julia
# This struct is typically loaded automatically
cfg = m._model_config  # where m is a MagikaConfig instance

println("Minimum file size for DL: \$(cfg.min_file_size_for_dl) bytes")
println("Medium confidence threshold: \$(cfg.medium_confidence_threshold)")
```
"""
struct ModelConfig
    beg_size::Int
    mid_size::Int
    end_size::Int
    use_inputs_at_offsets::Bool
    medium_confidence_threshold::Float32
    min_file_size_for_dl::Int
    padding_token::Int
    block_size::Int
    target_labels_space::Vector{ContentTypeLabel}
    thresholds::Dict{ContentTypeLabel, Float32}
    overwrite_map::Dict{ContentTypeLabel, ContentTypeLabel}
end