clear
clc

% %Toy system
% data = [1 1 5; 1 2 3; 1 4 1; 2 1 4; 2 4 1; 3 1 1; 3 2 1; 3 4 5; 4 1 1; 4 4 4; 5 2 1; 5 3 5; 5 4 4];
% R = cell(5,4);
% for i = 1:13
%     R{data(i,1),data(i,2)} = data(i,3);
% end

load stat_strain_prod.mat
load class_avg.mat
load prod_class_dict.mat

% loaded full dataset contains unique strain-product-titer tuples
% 1st column is strain #
% 2nd column is product #
% 3rd column is product class #
% 4th column is min titers
% 5th column is max titers
% 6th column is average titers
% 7th column is median titers
% 8th and 9th not useful

%%%%%%%%%%%%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%
%k = 10;
lam = 0.01;
max_iter = 200;
offset = 1; % 0 = without offset, 1 = with offset
tol = 0.05;
xval = 10; % xval-fold cross validation
epoch = 10;
statistic = 2; % 1 = max values, 2 = avg values, 3 = median values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


num_strain = max(stat_strain_prod(:,1));
num_prod = max(stat_strain_prod(:,2));
num_class = max(stat_strain_prod(:,3));

data = stat_strain_prod(:,[1 2 3 statistic+4]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Orig data processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data(:,4) = log10(data(:,4));

data_normalized = [];
for i = 1:num_class
    subtiter_class = data(data(:,3) == i,:);
    if size(subtiter_class,1) == 1
        data_normalized = [data_normalized;subtiter_class];
        continue
    end
    subtiter_class(:,4) = (subtiter_class(:,4)-min(subtiter_class(:,4))).*(10-1)./(max(subtiter_class(:,4))-min(subtiter_class(:,4)))+1;
    data_normalized = [data_normalized;subtiter_class];
end
data_normalized = data_normalized(:,[1 2 4]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Classifier data processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data_normalized = [];
% for i = 1:num_class
%     subtiter_class = data(data(:,3) == i,:);
%     subtiter_classification = subtiter_class;
%     subtiter_classification(subtiter_class(:,4) >= class_avg(i,2),4) = 1;
%     subtiter_classification(subtiter_class(:,4) < class_avg(i,2),4) = -1;
%     data_normalized = [data_normalized;subtiter_classification];
% end
% data_normalized = data_normalized(:,[1 2 4]);
%     



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Getting final results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % set max_iter to 10000
% % set proper k and lam values
% 
% R_pred = [];
% 
% for i = 1:epoch
%     rand_data = data_normalized(randperm(size(data_normalized,1)),:);
%     [U,V,b_u,b_v] = ALS(rand_data,k,lam,max_iter,tol,offset);
%     if offset == 1
%     b_u_mat = repmat(b_u,1,size(V,1));
%     b_v_mat = repmat(b_v,1,size(U,1))';
%     R_pred = [R_pred;U*V'+b_u_mat+b_v_mat];
%     else
%     R_pred = [R_pred;U*V'];
%     end
% end
% 
% R_pred_avg = zeros(num_strain,num_prod);
% 
% for i = 1:num_strain
%     for j = 1:num_prod
%         entries = zeros(10,1);
%         for k = 1:epoch
%             entries(k) = R_pred(i+num_strain*(k-1),j);
%         end
%         R_pred_avg(i,j) = mean(entries);
%     end
% end
% 
% 
% 
% R_pred_revert = [];
% 
% for i = 1:num_class
%     subproducts = prod_class_dict(prod_class_dict(:,2)==i,1)';    
%     subresults = R_pred_avg(:,subproducts);
%     subdata = data(data(:,3) == i,:);
%     if size(subtiter_class,1) == 1
%         R_pred_revert = [R_pred_revert,[subresults;subproducts]];
%         continue
%     end
%     maxi = max(subdata(:,4));
%     mini = min(subdata(:,4));
%     subresults = (subresults-1).*(maxi-mini)./(10-1)+mini;
%     R_pred_revert = [R_pred_revert,[subresults;subproducts]];
% end
% 
% R_pred_revert(1:end-1,:) = 10.^(R_pred_revert(1:end-1,:));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hyperparameter testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set max_iter to 200

interval = floor(linspace(1,size(data_normalized,1)+1,xval+1));
results = [];
for k = [10]

accuracy_val = zeros(epoch,xval);
accuracy_train = zeros(epoch,xval);
for j = 1:epoch
rand_data = data_normalized(randperm(size(data_normalized,1)),:);
for i = 1:xval
    data_val = rand_data(interval(i):interval(i+1)-1,:);
    data_train = rand_data;
    data_train(interval(i):interval(i+1)-1,:) = [];
    strain_train = unique(data_train(:,1));
    prod_train = unique(data_train(:,2));
    strain_dict = [strain_train,linspace(1,length(strain_train),length(strain_train))'];
    prod_dict = [prod_train,linspace(1,length(prod_train),length(prod_train))'];
    % for dicts,
    % 1st column contains original numbers in the training dataset
    % 2nd column contains the renewed numbers to have full matrix
    data_train_new = data_train;
    for x = 1:size(data_train,1)
        data_train_new(x,1) = strain_dict(strain_dict(:,1) == data_train(x,1),2);
        data_train_new(x,2) = prod_dict(prod_dict(:,1) == data_train(x,2),2);
    end
    
    % trimming validation data to include only those that can be validated
    strain_exclude = linspace(1,num_strain,num_strain)';
    prod_exclude = linspace(1,num_prod,num_prod)';
    strain_exclude = strain_exclude(~ismember(strain_exclude,strain_train));
    prod_exclude = prod_exclude(~ismember(prod_exclude,prod_train));
    for x = 1:length(strain_exclude)
        data_val(data_val(:,1) == strain_exclude(x),:) = [];
    end
    for x = 1:length(prod_exclude)
        data_val(data_val(:,2) == prod_exclude(x),:) = [];
    end
    
    % converting data_val old indicies into new indicies using dicts
    for x = 1:size(data_val,1)
        data_val(x,1) = strain_dict(strain_dict(:,1) == data_val(x,1),2);
        data_val(x,2) = prod_dict(prod_dict(:,1) == data_val(x,2),2);
    end
    
    [U,V,b_u,b_v] = ALS(data_train_new,k,lam,max_iter,tol,offset);
    
    b_u_mat = repmat(b_u,1,size(V,1));
    b_v_mat = repmat(b_v,1,size(U,1))';
   
    R_pred = U*V'+b_u_mat+b_v_mat;
%     R_pred = [prod_train';R_pred];
%     R_pred = [[0;strain_train],R_pred];
%     
%     R_pred_revert = R_pred;
%     for x = 2:size(R_pred,2)
%         index = R_pred(1,x);
%         index_class = prod_class_dict(prod_class_dict(:,1) == index,2);
%         subdata = data(data(:,3) == index_class,:);
%         maxi = max(subdata(:,4));
%         mini = min(subdata(:,4));
%         if maxi == mini
%             continue
%         end
%         R_pred_revert(2:end,x) = (R_pred(2:end,x)-1).*(maxi-mini)./(10-1)+mini;
%     end
%     R_pred_revert = R_pred_revert(2:end,2:end);
%     R_pred_revert = 10.^(R_pred_revert);
    
    results_val = zeros(size(data_val,1),1);
    for x = 1:size(data_val,1)
        results_val(x) = R_pred(data_val(x,1),data_val(x,2));
    end
    
    results_train = zeros(size(data_train_new,1),1);
    for x = 1:size(data_train_new,1)
        results_train(x) = R_pred(data_train_new(x,1),data_train_new(x,2));
    end
    
%     %%%%%%%%%%%%%%%%%%%% Orig scoring %%%%%%%%%%%%%%%%%%%%
%     linfit = fitlm(data_val(:,3),results_val);
%     %figure
%     %plot(data_val(:,3),results_val,'.');
%     rsq = linfit.Rsquared.Ordinary;
%     accuracy(j,i) = rsq;



    %%%%%%%%%%%%%%%%%%%% RMSE scoring %%%%%%%%%%%%%%%%%%%%
    rmse_val = sqrt(sum((results_val - data_val(:,3)).^2)/length(results_val));
    rmse_train = sqrt(sum((results_train - data_train_new(:,3)).^2)/length(results_train));
    accuracy_val(j,i) = rmse_val;
    accuracy_train(j,i) = rmse_train;
    
    
    %%%%%%%%%%%%%%%%%%%% Classifier scoring %%%%%%%%%%%%%%%%%%%%
%     count = 0;
%     for x = 1:size(data_val,1)
%         index_class = prod_class_dict(prod_class_dict(:,1) == data_val(x,2),2);
%         avg = class_avg(index_class,2);
%         if data_val(x,3) >= avg && results_val(x) >= avg
%             count = count + 1;
%         elseif data_val(x,3) < avg && results_val(x) < avg
%             count = count + 1;
%         end
%     end
%     accuracy(j,i) = count/size(data_val,1);
end
disp('======================================================')
disp('Current epoch:')
disp(j)
disp('Validation accuracy results:')
disp(accuracy_val(j,:))
disp('Training accuracy results:')
disp(accuracy_train(j,:))
end
mean_accuracy_val = mean(mean(accuracy_val));
mean_accuracy_train = mean(mean(accuracy_train));
disp('======================================================')
disp('Avg validation accuracy over all epochs:')
disp(mean_accuracy_val)
disp('Avg training accuracy over all epochs:')
disp(mean_accuracy_train)
results = [results; {k} {[mean_accuracy_val mean_accuracy_train]} {accuracy_val} {accuracy_train}];
end
disp('======================================================')
disp(results)













    
    
    
    
    
  
% for i = 1:size(R_pred,1)
%     for j = 1:size(R_pred,2)
%         if R_pred(i,j) > cutoff
%             R_pred(i,j) = 0;
%         elseif R_pred(i,j) < 0
%             R_pred(i,j) = 0;
%         end
%     end
% end

% R_pred_logic = zeros(size(R_pred));
% R_pred_logic(find(R_pred)) = 1;
% 
% num_strains = size(R_pred,1);
% num_products = size(R_pred,2);
% prod_by_strain = sum(R_pred_logic');
% strain_ranking = sortrows([prod_by_strain',linspace(1,num_strains,num_strains)'],'descend');
% strain_by_prod = sum(R_pred_logic);
% prod_ranking = sortrows([strain_by_prod',linspace(1,num_products,num_products)'],'descend');
% data_sorted_rows = zeros(num_strains,num_products);
% R_pred_sorted_rows = zeros(num_strains,num_products);
% for i = 1:num_strains
%     R_pred_sorted_rows(i,:) = R_pred(strain_ranking(i,2),:);
% end
% R_pred_sorted = zeros(num_strains,num_products);
% data_sorted_titer = zeros(num_strains,num_products);
% for j = 1:num_products
%     R_pred_sorted(:,j) = R_pred_sorted_rows(:,prod_ranking(j,2));
% end

% figure
% titer_heatmap = pcolor(R_pred); 
% colormap parula
% set(titer_heatmap,'EdgeColor','none'); 
% set(gca,'XTick',[],'YTick',[],'PlotBoxAspectRatio',[size(R_pred,2) size(R_pred,1) 1]);
% xlabel('Products','FontSize',18,'FontWeight','b')
% ylabel('Strains','FontSize',18,'FontWeight','b')
% cbar = colorbar;
% cbar.FontSize = 18;
% cbar.FontWeight = 'b';




%         if results_val(x) >= 1 && results_val(x) < 3.25
%             results_val(x) = 1; %poor
%         elseif results_val(x) >= 3.25 && results_val(x) < 5.5
%             results_val(x) = 2; %fair
%         elseif results_val(x) >= 5.5 && results_val(x) < 7.75
%             results_val(x) = 3; %good
%         else
%             results_val(x) = 4; %excellent
%         end
%         
%         if data_val(x,3) >= 1 && data_val(x,3) < 3.25
%             data_val(x,3) = 1; %poor
%         elseif data_val(x,3) >= 3.25 && data_val(x,3) < 5.5
%             data_val(x,3) = 2; %fair
%         elseif data_val(x,3) >= 5.5 && data_val(x,3) < 7.75
%             data_val(x,3) = 3; %good
%         else
%             data_val(x,3) = 4; %excellent
%         end