
W = 10;
H = 5;
segclass = zeros(50,1);
pairwise = sparse(50,50);
unary = zeros(7,50);
[X Y] = meshgrid(1:7, 1:7);
% labelcost = min(4, (X - Y).*(X - Y));
labelcost = 1 - eye(7,7);

for row = 0:H-1
  for col = 0:W-1
    pixel = 1+ row*W + col;
    if row+1 < H, pairwise(pixel, 1+col+(row+1)*W) = 0.1; end
    if row-1 >= 0, pairwise(pixel, 1+col+(row-1)*W) = 0.1; end 
    if col+1 < W, pairwise(pixel, 1+(col+1)+row*W) = 0.1; end
    if col-1 >= 0, pairwise(pixel, 1+(col-1)+row*W) = 0.1; end 
    if pixel == 1
      unary(:,pixel) = [110 1000 12 15 18 19 200]'; 
    elseif pixel <30
      unary(:,pixel) = [10 40.456 10 20 0.12 30 40]'; 
    else
      unary(:,pixel) = [1200 40 0.1 10 100 0.008 10]';     
    end
  end
end

segclass
unary
pairwise
labelcost
[labels E Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost),0);

fprintf('E: %d (should be 260), Eafter: %d (should be 44)\n', E, Eafter);
fprintf('unique(labels) should be [0 4] and is: [');
fprintf('%d ', unique(labels));
fprintf(']\n');
