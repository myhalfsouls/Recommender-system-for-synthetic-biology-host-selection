R_pred_classify = R_pred_revert;
for x = 1:size(R_pred_revert,2)
    for y = 1:size(R_pred_revert,1)-1
        index = R_pred_revert(end,x);
        index_class = prod_class_dict(prod_class_dict(:,1) == index,2);
        avg = class_avg(index_class,2);
        if R_pred_revert(y,x) >= avg
            R_pred_classify(y,x) = 1;
        else
            R_pred_classify(y,x) = -1;
        end
    end
end

R_pred_classify = sortrows(R_pred_classify',198)';
R_pred_classify = R_pred_classify(1:end-1,:);