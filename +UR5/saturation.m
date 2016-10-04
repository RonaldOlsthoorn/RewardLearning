function [ v_feed ] = saturation(v_feed)

for i = 1:6,
    
if(v_feed(i) < -1 )
    v_feed(i) = -1; 
elseif(v_feed(i) > 1 )
    v_feed(i) = 1; 
end

end