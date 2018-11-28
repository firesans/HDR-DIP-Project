function B = convert_ldr(A, a, b)

rad = convert_hdr(A, a);
B = hdr_ldr(rad, b);

end
