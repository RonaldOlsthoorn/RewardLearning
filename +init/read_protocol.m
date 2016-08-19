function protocol=read_protocol(protocol_name)
% parses the protocol file <protocol_name> -- the format of the
% protocol is explained in the file

fp = fopen(protocol_name,'r');
if fp == -1,
    error('Cannot open protocol file');
end

% read all lines, discard lines that start with comment sign
lineNr = 0;
count = 0;

while ~feof(fp),
    
    lineNr = lineNr+1;
    line = fgetl(fp);
    if numel(line) == 0 || line(1) == '%',
        continue;
    end
    
    count = count+1;
    
end

protocol = struct;
frewind(fp);

format = '%s %s';
line = textscan(fp, format, 'HeaderLines', lineNr-count);

for i=1:length(line{1,1})
    
    eval(sprintf('protocol.%s = %s;', char(line{1,1}(i,1)), char(line{1,2}(i,1))));
    
end
fclose(fp);
end