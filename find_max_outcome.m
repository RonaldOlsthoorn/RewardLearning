function [max_outcome, set,  max_epd] = find_max_outcome(S, rm, ro_par)   
    
    for s = 1:rm.n_segments
            
           roll_out.seg(s).sum_out = S.rollouts(1).sum_out(rm.seg_start(s),:);
           
    end
     
    max_outcome = roll_out;
    max_epd = rm.af(S, ro_par, rm, max_outcome);
    set = 'S';
    
    for i = 2:length(S.rollouts)
              
        for s = 1:rm.n_segments
            
           roll_out.seg(s).sum_out = S.rollouts(i).sum_out(rm.seg_start(s),:);
           
        end
        
        epd = rm.af(S, ro_par, rm, roll_out);
        
        if  epd > max_epd
            max_outcome = roll_out;
            max_epd = epd;
        end
    end
    
    for i = 1:length(rm.seg(1).R_expert)
        
        for s = 1:rm.n_segments
            
           roll_out.seg(s).sum_out = rm.seg(s).sum_out(i,:);
           
        end
        
        epd = rm.af(S, ro_par, rm, roll_out);
        
        if epd >= max_epd
            max_outcome = roll_out;
            set = 'D';
        end
    end
    
end