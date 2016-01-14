function [ k ] = test_random(  )
%UNTITLED2 summary of this function goes here
%   Detailed explanation goes here
x = 10;
k = 3;
x = insidefunc(x);
    function y = insidefunc(x)
        k = 2;
        y  = k*x;
    end


end

