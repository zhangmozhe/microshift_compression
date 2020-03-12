function weight = weight_compensate(D1,D2,alpha)

weight = 2/(1+exp(-alpha*abs(D1 - D2)));
% switch round(abs(D1-D2)/(32/9))
%     case 0
%         weight = 1;
%     case 1
%         weight = 1;
%     case 2
%         weight = 1.2;
%     case 3
%         weight = 1.4;
%     case 4
%         weight = 1.6;
%     case 5
%         weight = 1.8;
%     case 6
%         weight = 2.0;
%     case 7
%         weight = 2.2;
%     case 8
%         weight = 2.4;
%     otherwise
%         weight = 1;
% end
% weight = 1;
