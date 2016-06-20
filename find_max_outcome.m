function [max_outcome, set,  max_epd] = find_max_outcome(S, rm, ro_par)

    max_outcome = S.rollouts(1);
    max_epd = rm.af(S, ro_par, rm, max_outcome);
    set = 'S';
    
    for i = 2:length(S.rollouts)
        
        epd = rm.af(S, ro_par, rm, S.rollouts(i));
        
        if  epd > max_epd
            max_outcome = S.rollouts(i);
            max_epd = epd;
        end
    end
    
    for i = 1:length(rm.D)
        
        epd = rm.af(S, ro_par, rm, rm.D(i));
        
        if epd >= max_epd
            max_outcome = rm.D.(i);
            set = 'D';
        end
    end
    
end