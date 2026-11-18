if isinteractive()
    try
        using Revise
    catch e
        @warn "Could not load Revise" exception = (e, catch_backtrace())
    end

    try
        using TestPicker
        add_testitem_interface!()
        # Work around a TestPicker bug: a file with no code before its first test block
        # yields an empty `Vector{Any}` preamble, which has no matching method.
        @eval TestPicker.prepend_preamble_statements(
            i::TestPicker.TestBlockInterface, p::Vector
        ) = TestPicker.prepend_preamble_statements(i, convert(Vector{Expr}, p))
    catch e
        @warn "Could not load TestPicker" exception = (e, catch_backtrace())
    end
end
