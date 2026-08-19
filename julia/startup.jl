if isinteractive()
    try
        using Revise
    catch e
        @warn "Could not load Revise" exception = (e, catch_backtrace())
    end
end
