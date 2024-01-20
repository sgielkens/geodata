
q = 8

if ( q >= 1 && q <=30 )
  a0 = 9.9262
  a1 = 0.90076
  a2 = 5.6839 * 10^-4
  a3 = -3.4342 * 10^-6
elseif ( q >= 31 && q <= 100 )
  a0 = 9.8125
  a1 = 0.90982
  a2 = 3.1183 * 10^-4
  a3 = 8.0024 * 10^-7
else
  return
end

kritiek_waarde_chi2 = a0 + a1 * q + a2 * q^2 + a3 * q^3

kritiek_waarde_F = kritiek_waarde_chi2 / q
