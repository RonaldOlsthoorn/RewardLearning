classdef Summary < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        number_fails = 0;
        
        batch_res;
    end
    
    methods
        
        function add_result(obj, res)
            
            if res.succeeded==0
                obj.number_fails = obj.number_fails+1;
                return;
            end
            
            % print all trajectories                       
            n_iterations = length(res.Reward_trace);
             
            res_sum.first_rollout = res.Reward_trace(1);
            res_sum.last_rollout = res.Reward_trace(end);
            
            if res.manual
                
                if strcmp(res.granularity, 'single')
                    l = length(res.Demo_trace);
                    D = zeros(l, 2);
                    
                    for i = 1:length(res.Demo_trace)
                        
                        D(i,1) = res.Demo_trace(i).iteration_queried;
                        D(i,2) = res.Demo_trace(i).R_expert;
                    end
                    
                    R = zeros(1,n_iterations);
                    R_var = zeros(1,n_iterations);
                    
                    for i = 1:n_iterations
                        
                        R(i) = res.Reward_trace(i).R;
                        R_var(i) = res.Reward_trace(i).R_var;
                        
                    end
                    
                else
                    
                    R = zeros(n_iterations-1, 4);
                    R_var = zeros(n_iterations-1, 4);
                    
                    for i = 1:4
                        
                        l = length(res.Demo_trace{i});
                        d = zeros(l,2);
                        
                        for j = 1:l
                            
                            d(j,1) = res.Demo_trace{i}(j).iteration_queried;
                            d(j,2) = res.Demo_trace{i}(j).R_expert(i);
                        end
                        
                        D{i} = d;
                        
                        for j = 1:(n_iterations-1)
                            
                            if ~ isfield(res.Reward_trace(j), 'R_segments')
                                R(j,:) = [0 res.Reward_trace(j).R 0 0];
                                R_var(j,i) = res.Reward_trace(j).R_var(i);
                            else
                                
                                R(j,i) = res.Reward_trace(j).R_segments(i);
                                R_var(j,i) = res.Reward_trace(j).R_var(i);
                            end
                        end
                        
                    end

                end
                
                res_sum.R = R;
                res_sum.D = D;
                
            else
                
                n_iterations = length(res.Reward_trace);
                                
                if strcmp(res.granularity, 'single')
                    
                    R = zeros(1,n_iterations);
                    R_var = zeros(1,n_iterations);
                    R_true = zeros(1,n_iterations);
                    
                    for i = 1:n_iterations
                        
                        R(i) = res.Reward_trace(i).R;
                        R_var(i) = res.Reward_trace(i).R_var;
                        R_true(i) = res.Reward_trace(i).R_true;
                    end
                    l = length(res.Demo_trace);
                    D = zeros(l, 2);
                    
                    for i = 1:length(res.Demo_trace)
                        
                        D(i,1) = res.Demo_trace(i).iteration_queried;
                        D(i,2) = res.Demo_trace(i).R_expert;
                    end
                    
                else
                    
                    R = zeros(n_iterations-1, 4);
                    R_var = zeros(n_iterations-1, 4);
                    R_true = zeros(1,n_iterations);
                                        
                    for i = 1:4
                        
                        l = length(res.Demo_trace{i});
                        d = zeros(l,2);
                        
                        for j = 1:l
                            
                            d(j,1) = res.Demo_trace{i}(j).iteration_queried;
                            d(j,2) = res.Demo_trace{i}(j).R_expert(i);
                        end
                        
                        D{i} = d;
                        
                        for j = 1:(n_iterations-1)
                            
                            if ~ isfield(res.Reward_trace(j), 'R_segments')
                                R(j,:) = [0 res.Reward_trace(j).R 0 0];
                                R_var(j,i) = res.Reward_trace(j).R_var(i);
                                
                            else                                
                                R(j,i) = res.Reward_trace(j).R_segments(i);
                                R_var(j,i) = res.Reward_trace(j).R_var(i);
                                
                            end
                            
                            R_true(i) = res.Reward_trace(i).R_true;
                        end
                        
                    end
                    
                end
                
                res_sum.R = R;
                res_sum.R_var = R_var;
                res_sum.R_true = R_true;
                res_sum.D = D;        
            end
            
            res_sum.W = res.Weight_trace(end);                  
            
            if isempty(obj.batch_res)
                obj.batch_res = res_sum;
            else
                obj.batch_res(end+1) = res_sum;
            end
        end
        
        function res = to_struct(obj)
            
            res.batch_res = obj.batch_res;
        end
    end
    
end

