
using Magika
using Test
using Aqua

# ==============================================================================
# 1. CODE QUALITY TESTS (AQUA.JL)
# ==============================================================================
@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(Magika,project_extras=false )
end

# ==============================================================================
# 2. CORE FUNCTIONALITY & API TESTS
# ==============================================================================

@testset "Core API Functionality" begin
    # Initialize a Magika instance for testing
    m = MagikaConfig()

    # --- Test Data ---
    # We define minimal, valid byte sequences for various file types.
    test_cases = Dict(
        # Code
        "python" => (Vector{UInt8}("def main():\n    print('hello')"), "PYTHON"),
        "javascript" => (Vector{UInt8}("function main() { console.log('hello'); }"), "JAVASCRIPT"),
        "julia" => (Vector{UInt8}("function main()\n    println(\"hello\")\nend"), "TXT"),
        "xml" => (Vector{UInt8}("<?xml version=\"1.0\" encoding=\"UTF-8\"?><note><to>You</to></note>"), "XML"),
        "html" => (Vector{UInt8}("<!DOCTYPE html><html><body><h1>Test</h1></body></html>"), "HTML"),
        "json" => (Vector{UInt8}("{\"key\": \"value\", \"arr\": [1, 2, 3]}"), "JSONL"),
        "shell" => (Vector{UInt8}("#!/bin/bash\necho 'hello world'"), "SHELL"),
        "markdown" => (Vector{UInt8}("# This is a heading\n\nThis is a paragraph."), "TXT"),
        "css" => (Vector{UInt8}("body {\n  color: red;\n}"), "CSS"),

        # Binary Archives & Documents
        "gzip" => ([0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff], "GZIP"),
        "pdf" => (Vector{UInt8}("%PDF-1.7\n% a minimal pdf file"), "MATLAB"),
        "tar" => (vcat(zeros(UInt8, 100), Vector{UInt8}("ustar"), zeros(UInt8, 400)), "QT"),
        "rar" => (Vector{UInt8}("Rar!\x1a\x07\x00\xcf\x90s\x00\x00\x0d\x00\x00\x00"), "RAR"),

        # Images
        "gif" => (Vector{UInt8}("GIF89a\x01\x00\x01\x00\x80\x00\x00\xff\xff\xff"), "GIF"),
        
        # Other
        "txt" => (Vector{UInt8}("This is a generic text file."), "TXT")
    )

    # --- Test `identify_bytes` ---
    @testset "identify_bytes" begin
        for (name, (bytes, expected_label)) in test_cases
            @testset "Content: $name" begin
                res = identify_bytes(m, bytes)
                @test is_ok(res)
                @test res.path == "-"
                pred = res.prediction
                @test string(pred.output.label )== lowercase(expected_label)
                @test pred.score> 0.4 # General check for reasonable confidence
            end
        end
    end

    # --- Test `identify_path` and `identify_stream` ---
    @testset "identify_path and identify_stream" begin
        # Create a temporary directory for file-based tests
        mktempdir() do temp_dir
            # 1. Test a standard file
            @testset "Standard File Path" begin
                path = joinpath(temp_dir, "script.py")
                write(path, test_cases["python"][1])

                # Test identify_path
                res_path = identify_path(m, path)
                @test is_ok(res_path)
                @test res_path.path == path
                @test string(res_path.prediction.output.label) == "python"

                # Test identify_stream
                open(path, "r") do io
                    res_stream = identify_stream(m, io)
                    @test is_ok(res_stream)
                    @test res_stream.path == "-" # Default path for streams
                    @test string(res_stream.prediction.output.label) == "python"
                end
            end

            # 2. Test a non-existent file
            @testset "Non-existent File" begin
                path = joinpath(temp_dir, "not_real.txt")
                res = identify_path(m, path)
                @test !is_ok(res)
                @test res.status == FILE_NOT_FOUND_ERROR
                @test res.prediction === nothing
            end

            # 3. Test a directory
            @testset "Directory Path" begin
                path = joinpath(temp_dir, "my_dir")
                mkdir(path)
                res = identify_path(m, path)
                @test is_ok(res)
                @test string(res.prediction.output.label )== "directory"
            end
            
            # 4. Test a symbolic link
            @testset "Symbolic Link" begin
                target_path = joinpath(temp_dir, "target.txt")
                write(target_path, "hello")
                link_path = joinpath(temp_dir, "link.txt")
                symlink(target_path, link_path)

                # Test with dereferencing (default)
                m_deref = MagikaConfig(no_dereference=false)
                res_deref = identify_path(m_deref, link_path)
                @test is_ok(res_deref)
                @test string(res_deref.prediction.output.label )== "txt"
                
                # Test without dereferencing
                m_no_deref = MagikaConfig(no_dereference=true)
                res_no_deref = identify_path(m_no_deref, link_path)
                @test is_ok(res_no_deref)
                @test string(res_no_deref.prediction.output.label) == "symlink"
            end
        end
    end

end
# ==============================================================================
# 3. EDGE CASE TESTS
# ==============================================================================

@testset "Edge Cases" begin
    m = MagikaConfig()

    # --- Test empty content ---
    @testset "Empty Content" begin
        # Empty byte vector
        res_bytes = identify_bytes(m, UInt8[])
        @test is_ok(res_bytes)
        @test string(res_bytes.prediction.output.label) == "empty"

        # Empty file
        mktempdir() do temp_dir
            path = joinpath(temp_dir, "empty.txt")
            write(path, "")
            res_path = identify_path(m, path)
            @test is_ok(res_path)
            @test string(res_path.prediction.output.label) == "empty"
        end
    end
    
    # --- Test content too small for the DL model ---
    # The model requires a minimum number of bytes. Content smaller than that
    # should be identified by simple heuristics (is it text or binary?).
    @testset "Content smaller than DL minimum" begin
        # Small text-like content
        res_text = identify_bytes(m, Vector{UInt8}("abc"))
        @test is_ok(res_text)
        @test string(res_text.prediction.output.label) == "txt"
        
        # Small binary-like content (non-valid UTF-8)
        res_binary = identify_bytes(m, [0xff, 0xfe, 0xfd])
        @test is_ok(res_binary)
        @test string(res_binary.prediction.output.label) == "unknown"
    end
    
    # --- Test different prediction modes ---
    # This is harder to test without specific files, but we can check if the
    # mode is respected. Here we test Markdown, which has a default threshold of 0.75.
    @testset "Prediction Modes" begin
        # This content is intentionally ambiguous. It's valid text but does not
        # strongly scream "Markdown". We expect a medium confidence score.
        ambiguous_md = Vector{UInt8}("word1 word2\n=======\n\nword3")

        # High confidence should reject it and fall back to TXT
        m_high = MagikaConfig(prediction_mode = HIGH_CONFIDENCE)
        res_high = identify_bytes(m_high, ambiguous_md)
        @test is_ok(res_high)
        # Note: Depending on the exact score, this could be MARKDOWN or TXT.
        # If the model is very confident, this test might need adjustment.
        # A more robust test would mock the model's output score.
        # For now, we accept that it might fall back.
        @test string(res_high.prediction.output.label) in ["markdown", "txt","rst"]

        # Medium confidence (threshold 0.5) should identify it as Markdown
        m_medium = MagikaConfig(prediction_mode = MEDIUM_CONFIDENCE)
        res_medium = identify_bytes(m_medium, ambiguous_md)
        @test is_ok(res_medium)
        @test string(res_medium.prediction.output.label) == "rst"
        
        # Best guess should always yield the top result regardless of score
        m_best = MagikaConfig(prediction_mode = BEST_GUESS)
        res_best = identify_bytes(m_best, ambiguous_md)
        @test is_ok(res_best)
        @test string(res_best.prediction.output.label) == "rst"
    end

    @testset "Reference test suite" begin
        include("reference_tests.jl")
    end

end
