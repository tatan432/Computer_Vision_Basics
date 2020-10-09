function [H] = get_homograpgy_matrix(X,X_hat)

%%% X are the [x,y] co-ordinates which needs to be transformed to X_hat i.e. X_hat=H*X

X= double(X);
X_hat=double(X_hat);

A =zeros(8,8);
B= double(zeros(8,1))

for i=1:4
%     A(2*i-1,1:8)=[X(1,i), X(2,i), 1, 0, 0, 0, (-X_hat(1,i)*X(1,i)), (-X_hat(1,i)*X(2,i))];
%     A(2*i,1:8)=[0, 0, 0, X(1,i), X(2,i), 1, (-X_hat(2,i)*X(1,i)), (-X_hat(2,i)*X(2,i))]

    A(2*i-1,1:8)=[X(2,i), X(1,i), 1, 0, 0, 0, (-X_hat(2,i)*X(2,i)), (-X_hat(2,i)*X(1,i))];
    A(2*i,1:8)=[0, 0, 0, X(2,i), X(1,i), 1, (-X_hat(1,i)*X(2,i)), (-X_hat(1,i)*X(1,i))]
    B(2*i-1,1)=X_hat(2,i);
    B(2*i,1)=X_hat(1,i);
    
end

A=double(A)

 
Hmat= double(inv(A)*B);

h33 = sqrt ( 1/((sum(Hmat.*Hmat)+1)));
Hmat = h33*Hmat';
H = [Hmat(1,1:3);Hmat(1,4:6);Hmat(1,7:8),h33];

end

