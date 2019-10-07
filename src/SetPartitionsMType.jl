# This file is part of IntegerSequences.
# Copyright Peter Luschny. License is MIT.

(@__DIR__) ∉ LOAD_PATH && push!(LOAD_PATH, (@__DIR__))

module SetPartitionsMType

using Setpartitions, IntPartitions
export ModuleSetPartitionsMType

"""

general Definition

* exported functions
"""
const ModuleSetPartitionsMType = ""


# @cached_function
function P(m, n)
    n == 0 && return SR(1)
    sum(binomial(m*n, m*k)*P(m, n-k)*x for k in 1:n)
end

function S_Partitions(m, n, k)
    shapes = (map(x -> x*m, p) for p in IntegerPartitions(n, k))
    ################## [SetPartitions(sum(s), s).cardinality() for s in shapes]
end

# ArgumentError: reducing over an empty collection is not allowed
function SP_byLength(m, n)
    [sum(S_Partitions(m, n, k)) for k in 0:n]
end

function SP_byShape(m, n)
    [p for k in 0:n for p in S_Partitions(m, n, k)]
end

RowSum(m, n)  = sum(SP_byLength(m, n))
ARowSum(m, n) = sum((-1)^k*sum(S_Partitions(m, n, k)) for k in 0:n)
Diagonal(m,n) = S_Partitions(m, n, n)[0]
Central(m, n) = SP_byLength(m, 2n)[n]

#START-TEST-########################################################

using Test, SeqTests, SeqUtils

Tnum  = ["A008284", "A048993", "A156289", "A291451", "A291452"]
Anum  = ["A000012", "A036040", "A257490", "A327003", "A327004"]
Dnum  = ["A000012", "A000012", "A001147", "A025035", "A025036"]
Snum  = ["A000041", "A000110", "A005046", "A291973", "A291975"]
ASnum = ["A081362", "A000587", "A260884", "A291974", "A291976"]
Cnum  = ["A000041", "A007820", "A327416", "A327417", "A327418"]

function test()
end

function demo()
    for j in 0:4
        FUCK = 1
        m = j + FUCK
        println(); println()
        println( "--", m, "---------------------")
        println()
        println( "by Shape   ", Anum[m] )
        for n in 0:6 println( [n], SP_byShape(m, n) ) end
        println()
        println( [a for n in 0:4 for a in SP_byShape(m, n)] )
        println()
        println( "by Length  ", Tnum[m] )
        for n in 0:6 println( [n], SP_byLength(m, n) ) end
        println()
        if m > 0
            println( "by Reccur/k!" )
            L(n) = enumerate(P(m, n).list())
            for n in 0:6 println( [n], [p / factorial(k) for (k, p) in L(n)] ) end
            println()
            println( "by Reccurrence" )
            for n in 0:6 println( [n], P(m, n).list() ) end
            println()
        end
        println( [p for n in 0:5 for p in SP_byLength(m, n)] )
        println()
        println( "RowSum     ", Snum[m],  [RowSum(m, n)   for n in 0:6] )
        println( "AlterRowSum", ASnum[m], [ARowSum(m, n)  for n in 0:6] )
        println( "Diagonal   ", Dnum[m],  [Diagonal(m, n) for n in 0:6] )
        println( "Central    ", Cnum[m],  [Central(m, n)  for n in 0:5] )
    end
end

function perf()
end

function main()
    test()
    demo()
    perf()
end

main()

end # module

#=
@cached_function
def P(m, n):
    x = polygen(ZZ)
    if n == 0: return x^0
    p = sum(binomial(m*n, m*k)*P(m, n-k)*x for k in (1..n))
    return expand(p)

print [P(3, n).leading_coefficient()//factorial(n) for n in (0..6)]
=3

#=

('--', 0, '---------------------')

by Shape    A000012
[0] [1]
[1] [1]
[2] [1, 1]
[3] [1, 1, 1]
[4] [1, 1, 1, 1, 1]
[5] [1, 1, 1, 1, 1, 1, 1]
[6] [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

by Length   A008284
[0] [1]
[1] [0, 1]
[2] [0, 1, 1]
[3] [0, 1, 1, 1]
[4] [0, 1, 2, 1, 1]
[5] [0, 1, 2, 2, 1, 1]
[6] [0, 1, 3, 3, 2, 1, 1]

[1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 2, 1, 1, 0, 1, 2, 2, 1, 1]

RowSum      A000041 [1, 1, 2, 3, 5, 7, 11]
AlterRowSum A081362 [1, -1, 0, -1, 1, -1, 1]
Diagonal    A000012 [1, 1, 1, 1, 1, 1, 1]
Central     A000041 [1, 1, 2, 3, 5, 7]


('--', 1, '---------------------')

by Shape    A036040
[0] [1]
[1] [1]
[2] [1, 1]
[3] [1, 3, 1]
[4] [1, 4, 3, 6, 1]
[5] [1, 5, 10, 10, 15, 10, 1]
[6] [1, 6, 15, 10, 15, 60, 15, 20, 45, 15, 1]

[1, 1, 1, 1, 1, 3, 1, 1, 4, 3, 6, 1]

by Length   A048993
[0] [1]
[1] [0, 1]
[2] [0, 1, 1]
[3] [0, 1, 3, 1]
[4] [0, 1, 7, 6, 1]
[5] [0, 1, 15, 25, 10, 1]
[6] [0, 1, 31, 90, 65, 15, 1]

by Reccur/k!
[0] [1]
[1] [0, 1]
[2] [0, 1, 1]
[3] [0, 1, 3, 1]
[4] [0, 1, 7, 6, 1]
[5] [0, 1, 15, 25, 10, 1]
[6] [0, 1, 31, 90, 65, 15, 1]

by Reccurrence
[0] [1]
[1] [0, 1]
[2] [0, 1, 2]
[3] [0, 1, 6, 6]
[4] [0, 1, 14, 36, 24]
[5] [0, 1, 30, 150, 240, 120]
[6] [0, 1, 62, 540, 1560, 1800, 720]

[1, 0, 1, 0, 1, 1, 0, 1, 3, 1, 0, 1, 7, 6, 1, 0, 1, 15, 25, 10, 1]

RowSum      A000110 [1, 1, 2, 5, 15, 52, 203]
AlterRowSum A000587 [1, -1, 0, 1, 1, -2, -9]
Diagonal    A000012 [1, 1, 1, 1, 1, 1, 1]
Central     A007820 [1, 1, 7, 90, 1701, 42525]


('--', 2, '---------------------')

by Shape    A257490
[0] [1]
[1] [1]
[2] [1, 3]
[3] [1, 15, 15]
[4] [1, 28, 35, 210, 105]
[5] [1, 45, 210, 630, 1575, 3150, 945]
[6] [1, 66, 495, 462, 1485, 13860, 5775, 13860, 51975, 51975, 10395]

[1, 1, 1, 3, 1, 15, 15, 1, 28, 35, 210, 105]

by Length   A156289
[0] [1]
[1] [0, 1]
[2] [0, 1, 3]
[3] [0, 1, 15, 15]
[4] [0, 1, 63, 210, 105]
[5] [0, 1, 255, 2205, 3150, 945]
[6] [0, 1, 1023, 21120, 65835, 51975, 10395]

by Reccur/k!
[0] [1]
[1] [0, 1]
[2] [0, 1, 3]
[3] [0, 1, 15, 15]
[4] [0, 1, 63, 210, 105]
[5] [0, 1, 255, 2205, 3150, 945]
[6] [0, 1, 1023, 21120, 65835, 51975, 10395]

by Reccurrence
[0] [1]
[1] [0, 1]
[2] [0, 1, 6]
[3] [0, 1, 30, 90]
[4] [0, 1, 126, 1260, 2520]
[5] [0, 1, 510, 13230, 75600, 113400]
[6] [0, 1, 2046, 126720, 1580040, 6237000, 7484400]

[1, 0, 1, 0, 1, 3, 0, 1, 15, 15, 0, 1, 63, 210, 105, 0, 1, 255, 2205, 3150, 945]

RowSum      A005046 [1, 1, 4, 31, 379, 6556, 150349]
AlterRowSum A260884 [1, -1, 2, -1, -43, 254, 4157]
Diagonal    A001147 [1, 1, 3, 15, 105, 945, 10395]
Central     A327416 [1, 1, 63, 21120, 20585565, 44025570225]


('--', 3, '---------------------')

by Shape    A327003
[0] [1]
[1] [1]
[2] [1, 10]
[3] [1, 84, 280]
[4] [1, 220, 462, 9240, 15400]
[5] [1, 455, 5005, 50050, 210210, 1401400, 1401400]
[6] [1, 816, 18564, 24310, 185640, 4084080, 2858856, 13613600, 85765680, 285885600, 190590400]

[1, 1, 1, 10, 1, 84, 280, 1, 220, 462, 9240, 15400]

by Length   A291451
[0] [1]
[1] [0, 1]
[2] [0, 1, 10]
[3] [0, 1, 84, 280]
[4] [0, 1, 682, 9240, 15400]
[5] [0, 1, 5460, 260260, 1401400, 1401400]
[6] [0, 1, 43690, 7128576, 99379280, 285885600, 190590400]

by Reccur/k!
[0] [1]
[1] [0, 1]
[2] [0, 1, 10]
[3] [0, 1, 84, 280]
[4] [0, 1, 682, 9240, 15400]
[5] [0, 1, 5460, 260260, 1401400, 1401400]
[6] [0, 1, 43690, 7128576, 99379280, 285885600, 190590400]

by Reccurrence
[0] [1]
[1] [0, 1]
[2] [0, 1, 20]
[3] [0, 1, 168, 1680]
[4] [0, 1, 1364, 55440, 369600]
[5] [0, 1, 10920, 1561560, 33633600, 168168000]
[6] [0, 1, 87380, 42771456, 2385102720, 34306272000, 137225088000]

[1, 0, 1, 0, 1, 10, 0, 1, 84, 280, 0, 1, 682, 9240, 15400, 0, 1, 5460, 260260, 1401400, 1401400]

RowSum      A291973 [1, 1, 11, 365, 25323, 3068521, 583027547]
AlterRowSum A291974 [1, -1, 9, -197, 6841, -254801, -3000807]
Diagonal    A025035 [1, 1, 10, 280, 15400, 1401400, 190590400]
Central     A327417 [1, 1, 682, 7128576, 429120851544, 94066556834970720]


('--', 4, '---------------------')

by Shape    A327004
[0] [1]
[1] [1]
[2] [1, 35]
[3] [1, 495, 5775]
[4] [1, 1820, 6435, 450450, 2627625]
[5] [1, 4845, 125970, 4408950, 31177575, 727476750, 2546168625]
[6] [1, 10626, 735471, 1352078, 25741485, 1338557220, 1577585295, 15616500900, 165646455975, 1932541986375, 4509264634875]

[1, 1, 1, 35, 1, 495, 5775, 1, 1820, 6435, 450450, 2627625]

by Length   A291452
[0] [1]
[1] [0, 1]
[2] [0, 1, 35]
[3] [0, 1, 495, 5775]
[4] [0, 1, 8255, 450450, 2627625]
[5] [0, 1, 130815, 35586525, 727476750, 2546168625]
[6] [0, 1, 2098175, 2941884000, 181262956875, 1932541986375, 4509264634875]

by Reccur/k!
[0] [1]
[1] [0, 1]
[2] [0, 1, 35]
[3] [0, 1, 495, 5775]
[4] [0, 1, 8255, 450450, 2627625]
[5] [0, 1, 130815, 35586525, 727476750, 2546168625]
[6] [0, 1, 2098175, 2941884000, 181262956875, 1932541986375, 4509264634875]

by Reccurrence
[0] [1]
[1] [0, 1]
[2] [0, 1, 70]
[3] [0, 1, 990, 34650]
[4] [0, 1, 16510, 2702700, 63063000]
[5] [0, 1, 261630, 213519150, 17459442000, 305540235000]
[6] [0, 1, 4196350, 17651304000, 4350310965000, 231905038365000, 3246670537110000]

[1, 0, 1, 0, 1, 35, 0, 1, 495, 5775, 0, 1, 8255, 450450, 2627625, 0, 1, 130815, 35586525, 727476750, 2546168625]

RowSum      A291975 [1, 1, 36, 6271, 3086331, 3309362716, 6626013560301]
AlterRowSum A291976 [1, -1, 34, -5281, 2185429, -1854147586, 2755045819549]
Diagonal    A025036 [1, 1, 35, 5775, 2627625, 2546168625, 4509264634875]
Central     A327418 [1, 1, 8255, 2941884000, 11957867341948125, 294040106448733743008625]

=#
