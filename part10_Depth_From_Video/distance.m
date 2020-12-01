function [dist] = distance( c1, c2 )
dist =  (abs(c1(1,1) - c2(1,1))+ abs(c1(2,1) - c2(2,1)) + abs(c1(3,1) - c2(3,1)))/3;
end