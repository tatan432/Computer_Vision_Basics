function [is,js] = connect_edges(height,width)

% no_nodes= height1*width1;
% sparse_i = zeros(4*no_nodes,1);
% sparse_j = zeros(4*no_nodes,1);
% 
% count=0;
% % Create Prior Edges
% for row = 1:height1
%     for col = 1:width1
% 
%         node= (row-1)*width1+col;
%         if row < height1
%             count = count + 1;
%             sparse_i(count,1) = node;
%             sparse_j(count,1) = node + width1;
%         end
%         if row > 1
%             count = count + 1;
%             sparse_i(count,1) = node;
%             sparse_j(count,1) = node - width1;
%         end
%         if col < width1
%             count = count + 1;
%             sparse_i(count,1) = node;
%             sparse_j(count,1) = node + 1;
%         end
%         if col > 1
%             count = count + 1;
%             sparse_i(count,1) = node;
%             sparse_j(count,1) = node - 1;
%         end
%     end
% end

no_nodes = height*width;
IS = []; JS = [];

sparse_i = [1:no_nodes]'; 
sparse_i([height:height:no_nodes])=[];
sparse_j = sparse_i+1;
IS = [IS;sparse_i;sparse_j];
JS = [JS;sparse_j;sparse_i];


sparse_i = [1:no_nodes-height]';
sparse_j = sparse_i+height;
IS = [IS;sparse_i;sparse_j];
JS = [JS;sparse_j;sparse_i];

is=IS;
js=JS;

end

