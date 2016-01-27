% does not work %
rawimg_des01 = simscene_globalDoublet0121(1);
rawimg_des16 = simscene_globalDoublet0121(16);

save rawimg_des01
save rawimg_des02

[ camera_array_nocorr, rmse_array_nocorr, init_ind_nocorr ] = ...
    test_optimizeDoublet_global( 'nocorr' );

[ camera_array_corr, rmse_array_corr, init_ind_corr ] = ...
    test_optimizeDoublet_global( 'corr' );
