for i = 1:16
    h = subplot(4,4,i);
    viz_camera(all_cameras(i,:), h)
    title([ num2str(sorted_rmse(i)*1000) ' um'])
end