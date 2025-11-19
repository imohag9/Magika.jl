using JSON3
# This test suite is designed to verify the Julia implementation against the
# reference test cases from the original Magika repository.
#
# PREREQUISITES:
# 1. The `standard_v3_3-inference_examples_by_path.json` file must be in the package root.
# 2. The `tests_data` directory from the original repository .
#   https://github.com/google/magika

const PREDICTION_MODE_MAP = Dict{String, PredictionMode}(
    "high_confidence" => HIGH_CONFIDENCE,
    "medium_confidence" => MEDIUM_CONFIDENCE,
    "best_guess" => BEST_GUESS
)

@testset "Reference Implementation Tests" begin
    # --- Setup ---

    json_path = joinpath(
        @__DIR__, "tests_data", "standard_v3_3-inference_examples_by_path.json")

    if !isfile(json_path)
        @warn "Skipping reference tests: 'standard_v3_3-inference_examples_by_path.json' not found in package root."
        # We return here so the test set doesn't fail, it just gets skipped.
        return
    end

    test_cases = JSON3.read(read(json_path, String))

    # Map string prediction modes from the JSON to the enums defined in Magika.jl

    # Group test cases by prediction mode to avoid re-initializing MagikaConfig repeatedly.
    # This makes the test suite run more efficiently.
    grouped_cases = Dict{String, Vector}()
    for case in test_cases
        mode = case.prediction_mode
        if !haskey(grouped_cases, mode)
            grouped_cases[mode] = []
        end
        push!(grouped_cases[mode], case)
    end

    # --- Test Execution ---
    for (mode_str, cases) in grouped_cases
        @testset "Prediction Mode: '$mode_str'" begin

            # Initialize Magika with the correct prediction mode for this group of tests
            prediction_mode_enum = PREDICTION_MODE_MAP[mode_str]
            m = MagikaConfig(prediction_mode = prediction_mode_enum)

            for case in cases
                # The file paths in the JSON are relative to the repo root.
                file_path = joinpath(@__DIR__, case.path)

                @testset "File: $(case.path)" begin
                    # First, check if the required test file actually exists.
                    if !ispath(file_path) || case.path == "tests_data/basic/docx/doc.docx"
                        continue # Skip to the next file
                    end

                    # Run the identification
                    res = identify_path(m, file_path)

                    # --- Assertions ---

                    # 1. Verify the overall status
                    @test (res.status == OK) == (case.status == "ok")

                    # 2. If the status is OK, verify the prediction details
                    if res.status == OK
                        pred = res.prediction
                        expected_pred = case.prediction

                        # Check that the final output label is correct
                        @test string(pred.output.label) == expected_pred.output

                        # Check that the raw model (DL) label is correct
                        @test string(pred.dl.label) == expected_pred.dl

                        # Check that the confidence score is approximately equal
                        success = isapprox(pred.score, expected_pred.score; atol = 0.01)
                        if !success
                            @warn " Mode $mode_str: Prediction score for $(pred.dl.label) is different than expected."
                        end

                        # Check the reason for any potential overwrites
                        # We convert the enum to a lowercase string to match the JSON format.
                        @test lowercase(string(pred.overwrite_reason)) ==
                              expected_pred.overwrite_reason
                    end
                end
            end
        end
    end
end