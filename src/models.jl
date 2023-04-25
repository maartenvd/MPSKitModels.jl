#################
## Ising model ##
#################


"""
    classical_ising(; beta=log(1+sqrt(2))/2)

MPO for the classical Ising partition function, defined by
    ``Z(β) = ∑_s exp(-βH(s))`` with ``H(s) = ∑_{<i,j>}σ_i σ_j``
"""
function classical_ising(eltype=ComplexF64, ::ℤ{1}=ℤ{1}, lattice=InfiniteChain(1);
                         beta=log(1 + sqrt(2)) / 2)
    t = [exp(beta) exp(-beta); exp(-beta) exp(beta)]

    r = eigen(t)
    nt = r.vectors * sqrt(Diagonal(r.values)) * r.vectors

    O = zeros(2, 2, 2, 2)
    O[1, 1, 1, 1] = 1
    O[2, 2, 2, 2] = 1

    @tensor o[-1 -2; -3 -4] := O[1 2; 3 4] * nt[-1; 1] * nt[-2; 2] * nt[-3; 3] * nt[-4; 4]

    return InfiniteMPO(TensorMap(complex(o), ℂ^2 * ℂ^2, ℂ^2 * ℂ^2))
end

function classical_ising(eltype, ::ℤ₂, lattice=InfiniteChain(1);
                         beta=log(1 + sqrt(2)) / 2)
    x = cosh(beta)
    y = sinh(beta)

    sec = ℤ₂Space(0 => 1, 1 => 1)
    mpo = TensorMap(zeros, ComplexF64, sec * sec, sec * sec)
    blocks(mpo)[Irrep[ℤ₂](0)] = [2x^2 2x*y; 2x*y 2y^2]
    blocks(mpo)[Irrep[ℤ₂](1)] = [2x*y 2x*y; 2x*y 2x*y]

    return InfiniteMPO(mpo)
end

"""
    sixvertex(; a=1.0, b=1.0, c=1.0)

MPO for the six vertex model.
"""
function sixvertex(eltype=ComplexF64, ::ℤ{1}=ℤ{1}, lattice=InfiniteChain(1);
                   a=1.0, b=1.0, c=1.0)
    d = [a 0 0 0
         0 c b 0
         0 b c 0
         0 0 0 a]
    return InfiniteMPO(permute(TensorMap(complex(d), ℂ^2 ⊗ ℂ^2, ℂ^2 ⊗ ℂ^2), (1, 2), (4, 3)))
end

function sixvertex(eltype, ::U₁, lattice=InfiniteChain(1);
                   a=1.0, b=1.0, c=1.0)
    pspace = U1Space(-1 => 1, 1 => 1)
    mpo = TensorMap(zeros, eltype, pspace ⊗ pspace, pspace ⊗ pspace)
    blocks(mpo)[Irrep[U₁](0)] = [b c; c b]
    blocks(mpo)[Irrep[U₁](2)] = reshape([a], (1, 1))
    blocks(mpo)[Irrep[U₁](-2)] = reshape([a], (1, 1))
    return InfiniteMPO(permute(mpo, (1, 2), (4, 3)))
end

function sixvertex(eltype, ::CU₁, lattice=InfiniteChain(1);
                   a=1.0, b=1.0, c=1.0)
    pspace = CU1Space(1 // 2 => 1)
    mpo = TensorMap(zeros, eltype, pspace ⊗ pspace, pspace ⊗ pspace)
    blocks(mpo)[Irrep[CU₁](0, 0)] = reshape([b + c], (1, 1))
    blocks(mpo)[Irrep[CU₁](0, 1)] = reshape([-b + c], (1, 1))
    blocks(mpo)[Irrep[CU₁](1, 2)] = reshape([a], (1, 1))
    return InfiniteMPO(permute(mpo, (1, 2), (4, 3)))
end