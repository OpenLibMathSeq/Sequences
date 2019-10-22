# This file is part of IntegerSequences.
# Copyright Peter Luschny. License is MIT.

# Builds the modules Sequences, runtests and perftests from the src modules.
#
# The source files are scanned and the source modules are joined together,
# not merely included. This architecture has three advantages:
# * Source and test modules can be placed in the same file.
# * A uniform layout of the source modules is enforced.
# * The build can be easily customized by filtering source files.

(@__DIR__) ∉ LOAD_PATH && push!(LOAD_PATH, (@__DIR__))

module BuildSequences
using Dates, UUIDs
export build_all

cloudpath = "https://github.com/OpenLibMathSeq/IntegerSequences.jl/blob/master/src/"

pkgdir = dirname((@__DIR__))
@info("Package directory is: " * pkgdir)

srcdir = dirname((@__FILE__))
cd(srcdir)
@info("Working directory is: " * pwd())

tstdir = joinpath(pkgdir, "test")
@info("Test files are in:    " * tstdir)

docdir = joinpath(pkgdir, "docs")
@info("Docs directory is:    " * docdir)

docsrcdir = joinpath(docdir, "src")
@info("Docs sources are in:  " * docsrcdir)
@info("The following modules are included in IntegerSequences.jl:")

exclude = [
    "TemplateModule.jl",
    "BuildSequences.jl",
    "IntegerSequences.jl",
    "SeqTests.jl",
    "Factorization.jl",
    "_EXPORT.jl",
    "_TEMP.jl",
    "_INDEX.jl",
    "_SINDEX.jl",
    "_IS.jl",
    "tempCodeRunnerFile.jl"
]

function header(f)
    println(f, "# This file is part of IntegerSequences.")
    println(f, "# Copyright Peter Luschny. License is MIT.")
    println(f, "# This file includes parts from Combinatorics.jl in modified form." )
    println(f)
    println(f, "# Version of: UTC ", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))
    println(f, "# ", UUIDs.uuid1())
    println(f)
    println(f, "# Do not edit this file, it is generated from the modules and will be overwritten!" )
    println(f, "# Edit the modules in the src directory and build this file with BuildSequences.jl!" )
    println(f)
end

function sortnames()

    index = open("_INDEX.jl", "r")
    sindex = open("_SINDEX.jl", "w")

    dict = Dict{Int64,Array{String}}()

    # prefixes
    # C => Channel
    # F => Filter (all below n)
    # G => Generating function
    # I => Iteration
    # L => List (array based)
    # M => Matrix
    # P => Polynomial
    # R => RealFunction
    # S => Staircase (iteration)
    # T => Triangle (iteration)
    # TL => Triangle (triangular array, list of rows)
    # TF => Triangle (flat-list array)
    # V => Value
    # is => is a (predicate), boolean

    for l in eachline(index, keep = true)

        i = 0
        c = 2
        if occursin(r"^[ACFGILMPRSTV][0-9]{6},$", l)
            c = 0
        end
        if occursin(r"^is[0-9]{6},$", l) || occursin(r"^TL[0-9]{6},$", l) || occursin(r"^TF[0-9]{6},$", l)
            i = 2
            c = 0
        end

        c == 2 && (print(sindex, l); continue)

        Anum = l[1:end-2]
        N = Meta.parse(Anum[2+i:end-c])

        if !haskey(dict, N)
            dict[N] = [Anum]
        else
            push!(dict[N], Anum)
        end
    end

    # We have to avoid the final comma in the export list
    K = sort(collect(keys(dict)))
    for key in K[1:end-1]
        for s in dict[key]
            print(sindex, s * ",")
        end
        println(sindex)
    end

    E = dict[K[end]]
    for s in E[1:end-1]
        print(sindex, s * ",")
    end
    println(sindex, E[end])

    close(index)
    close(sindex)
end

# Nota bene: we make use of the convention that an Sequences module
# is closed by "end # module" (and not merely by "end")!
function build_seq()

    tmp = open("_TEMP.jl", "w")
    exp = open("_EXPORT.jl", "w")

    seq_modules = filter!(s -> occursin(r"\.jl$", s), readdir(srcdir))

    for filename in seq_modules
        filename in exclude && continue
        path = joinpath(srcdir, filename)
        mod = open(path, "r")
        println(" + ", filename)
        println(tmp, "# *** ", splitdir(path)[2], " ****************")
        doc = false
        mlcomment = false

        for l in eachline(mod, keep = true)

            n = lstrip(l)
            if mlcomment && startswith(n, "=#")
                mlcomment = false
                continue
            end
            if mlcomment || startswith(n, "#=")
                mlcomment = true
                continue
            end
            startswith(n, "#START-TEST") && break
            startswith(n, "end # module") && break

            startswith(n, '#') && continue
            startswith(n, "using") && continue
            startswith(n, "module") && continue
            startswith(n, "(@__DIR__)") && continue
            startswith(n, "__precompile__") && continue

            startswith(n, "\"\"\"") && (doc = !doc)
            if doc
                print(tmp, l)
                continue
            end

            if startswith(n, "export")
                print(exp, n)
                continue
            end

            print(tmp, n)
        end
        close(mod)
    end

    flush(exp)
    close(exp)
    flush(tmp)
    close(tmp)

    sleep(0.1)
    exp = open("_EXPORT.jl", "r")
    sor = open("_INDEX.jl", "w")

    s = ""
    for l in eachline(exp, keep = true)
        n = lstrip(l)
        if startswith(n, "export")
            n = n[7:end]
        end
        s *= n
    end
    R = replace(s, ',' => ' ')
    T = sort(split(R))

    println(sor, "export ")
    for t in T[1:end]
        println(sor, t, ",")
    end

    close(sor)
    close(exp)
    sleep(0.01)

    sortnames()

    tmp = open("_TEMP.jl", "r")
    sor = open("_SINDEX.jl", "r")
    target = joinpath(srcdir, "_IS.jl")
    olm = open(target, "w")
    header(olm)
    println(olm, "__precompile__()")

    println(olm, "module IntegerSequences")
    println(olm, "using Nemo, IterTools, HTTP, DocStringExtensions")
    # println(olm, "import AbstractAlgebra.lead")

    for l in eachline(sor, keep = true)
        print(olm, l)
    end

    for l in eachline(tmp, keep = true)
        print(olm, l)
    end
    print(olm, "end")

    close(sor)
    close(tmp)
    close(olm)
end

# Builds the file test/runtests.jl from the Sequences modules.
# Nota bene: we make use of the convention that a Sequences module
# has three functions: test(), demo() and perf(), in this order.
function build_test()
    path = joinpath(tstdir, "runtests.jl")
    o = open(path, "w")
    header(o)

    println(o, "tstdir = realpath(joinpath(dirname(@__FILE__)))")
    println(o, "srcdir = joinpath(dirname(tstdir), \"src\")")
    println(o, "tstdir ∉ LOAD_PATH && push!(LOAD_PATH, tstdir)")
    println(o, "srcdir ∉ LOAD_PATH && push!(LOAD_PATH, srcdir)")

    println(o, "module runtests")
    println(
        o,
        "using Nemo, Test, SeqTests, IntegerSequences, IterTools, Combinatorics"
    )

    path = joinpath(tstdir, "runtests.jl")
    i = open(path, "r")
    buff = Array{String,1}()
    for l in eachline(i, keep = true)
        n = lstrip(l)
        startswith(n, '#') && continue
        startswith(n, "module") && continue
        startswith(n, "using") && continue
        startswith(n, "export") && continue
        push!(buff, n)
    end
    j = length(buff)
    while j > 0 && buff[j] == ""
        j -= 1
    end

    for k in 1:j-1
        print(o, buff[k])
    end
    close(i)

    seq_modules = filter!(s -> occursin(r"\.jl$", s), readdir(srcdir))
    for filename in seq_modules
        filename in exclude && continue
        path = joinpath(srcdir, filename)
        i = open(path, "r")
        inside = false
        println(o, "# *** ", splitdir(path)[2], " *********")

        buff = Array{String,1}()
        for l in eachline(i, keep = true)
            n = lstrip(l)
            startswith(n, '#') && continue
            b = startswith(n, "function test")
            if b
                inside = true
                continue
            end

            if inside
                c = startswith(n, "function") && n[10] ≠ 't'
                if c
                    break
                end
                push!(buff, n)
            end
        end

        j = length(buff)
        while j > 0 && buff[j] == ""
            j -= 1
        end

        for k in 1:j-1
            print(o, buff[k])
        end
        close(i)
    end
    print(o, "end # module")
    close(o)
end

# Builds the file test/perftests.jl.
function build_perf()
    path = joinpath(tstdir, "perftests.jl")
    o = open(path, "w")

    header(o)
    println(o, "tstdir = realpath(joinpath(dirname(@__FILE__)))")
    println(o, "srcdir = joinpath(dirname(tstdir), \"src\")")
    println(o, "tstdir ∉ LOAD_PATH && push!(LOAD_PATH, tstdir)")
    println(o, "srcdir ∉ LOAD_PATH && push!(LOAD_PATH, srcdir)")

    println(o, "module perftests")
    println(o, "using IntegerSequences, Dates, InteractiveUtils")

    println(o, "InteractiveUtils.versioninfo()")
    println(o, "start = Dates.now()")

    seq_modules = filter!(s -> occursin(r"\.jl$", s), readdir(srcdir))
    for filename in seq_modules
        filename in exclude && continue
        path = joinpath(srcdir, filename)
        i = open(path, "r")
        inside = false
        println(o, "# +++ ", filename, " +++")

        buff = Array{String,1}()
        s = ""
        for l in eachline(i, keep = true)
            n = lstrip(l)
            b = startswith(n, "function perf()")
            if b
                inside = true
                continue
            end
            if inside
                c = startswith(n, "function main")
                if c
                    break
                end
                startswith(n, '#') && continue
                if startswith(n, "@time")
                    s = chomp(n[7:end]) * "\")\n"
                    push!(buff, "println(\"\\nTEST: ", s)
                end
                push!(buff, n)
            end
        end

        j = length(buff)
        while j > 0 && buff[j] == ""
            j -= 1
        end

        for k in 1:j-1
            print(o, buff[k])
        end
        close(i)
    end

    println(o, "stop = Dates.now()")
    println(o, "tdiff = stop - start")
    println(o, "println(\"\\nJulia version: \" * string(VERSION) )")
    println(o, "println(start)")
    println(o, "println(\"Total test time: \", tdiff)")
    println(o, "end # module")
    close(o)
end

# Builds the file index.md in docs/src.
function make_index()
    path = joinpath(docsrcdir, "index.md")
    ind = open(path, "w")
    tind = open("_SINDEX.jl", "r")

    first = true
    for l in eachline(tind, keep = false)
        if first
            first = false
            println(ind, "# Library")
            println(ind, "")
            continue
        end
        endswith(l, ',') && (l = chop(l))
        for f in split(l, ",")
            println(ind, "```@docs")
            println(ind, f)
            println(ind, "```")
        end
    end

    close(ind)
    close(tind)
end

function make_modules()

    mdpath = joinpath(docsrcdir, "modules.md")
    mod = open(mdpath, "w")
    seq_modules = filter!(s -> occursin(r"\.jl$", s), readdir(srcdir))

    for filename in seq_modules
        filename in exclude && continue
        path = joinpath(srcdir, filename)
        src = open(path, "r")
        indoc = false

        for l in eachline(src, keep = false)
            n = lstrip(l)
            if startswith(n, "\"\"\"")
                indoc && break
                indoc = true
                path = joinpath(cloudpath, filename)
                name = splitext(filename)
                println(mod, "\n   🔶  ", '[', name[1], "](", path, ")\n")
            else
                n = replace(n, "\\\\" => "\\")
                indoc && println(mod, n)
            end
        end
        close(src)
    end

    close(mod)
end

function addsig(srcfile, docfile)

    nextline(srcfile) =
        !eof(srcfile) ? (return readline(srcfile)) : (return nothing)
    n = nextline(srcfile)

    while true

        n == nothing && return
        while !startswith(n, "\"\"\"")
            println(docfile, n)
            n = nextline(srcfile)
            n == nothing && return
        end

        if startswith(n, "\"\"\"")
            println(docfile, n)
            n = nextline(srcfile)
            n == nothing && return
            while !startswith(n, "\"\"\"")
                println(docfile, n)
                n = nextline(srcfile)
                n == nothing && return
            end

            nn = nextline(srcfile)
            if !startswith(nn, "const Module")
                println(docfile, "\$(SIGNATURES)")
            end
            println(docfile, n)
            n = nn
        end
    end
end

function build_all()

    build_seq()

    srcdir = dirname(@__FILE__)
    srcfile = open(joinpath(srcdir, "_IS.jl"), "r")
    profile = open(joinpath(srcdir, "IntegerSequences.jl"), "w")
    addsig(srcfile, profile)
    close(srcfile)
    close(profile)

    build_test()
    build_perf()
    make_index()
    make_modules()

    rm("_EXPORT.jl")
    rm("_INDEX.jl")
    rm("_IS.jl")
    rm("_SINDEX.jl")
    rm("_TEMP.jl")
end

build_all()

end # module
