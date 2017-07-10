str = 'GreenPower LED toplighting Deep Red- White- Far Red- Medium Blue';
words_in_str = textscan(str,'%s');
strArr = words_in_str{1};
outputArr = cell(4,1);
index = 1;
for i=1:length(strArr)
    if index<=3
        if (length(outputArr{index})+length(strArr{i})) > 30
            index = index+1;
            outputArr{index} = [strArr{i},' '];
        else
            outputArr{index} = [ outputArr{index}, strArr{i},' '];
        end
    end
end
outputArr{4} = 'cost';
disp(outputArr)