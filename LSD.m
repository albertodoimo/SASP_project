function logdist = LSD(fft1,fft2)
    
    logratio = 20 * log10(fft1 ./ fft2);

    mean_square_lsd = mean(logratio .^ 2);

    logdist = sqrt(mean_square_lsd);

end