function nonsym_qstateclock_mpo(beta::Float64,q::Int)
    dat = zeros(ComplexF64,q,q,q,q);
    comega(d) = cos(2*pi*d/q);

    for i = 1:q, j = 1:q, k = 1:q, l = 1:q
        dat[i,j,k,l] = exp(beta*(comega(i-j) + comega(j-k) + comega(k-l) + comega(l-i)));
    end

    return PeriodicMPO(TensorMap(dat,ℂ^q*ℂ^q,ℂ^q*ℂ^q))
end
