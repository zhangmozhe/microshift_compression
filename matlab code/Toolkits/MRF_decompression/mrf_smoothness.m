function smoothcost = mrf_smoothness(p,Vmax)
% N_labels * N_labels

N_labels = 256;
smoothcost = zeros(N_labels, N_labels);
%% trancated norm 
for label1 = 1:N_labels
    for label2 = 1:N_labels
        smoothcost(label1,label2) = min(abs(label1-label2)^p, Vmax);
    end
end

% %% bilateral weight
% for label1 = 1:N_labels
%     for label2 = 1:N_labels
%         smoothcost(label1,label2) = abs(label1-label2)^p;
%     end
% end




smoothcost = int32(smoothcost);