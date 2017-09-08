classdef IESFile
    %IESFILE Reads an IES file and Stores the Data
    %
    
    properties
        Properties % this contains all LM-63-02 defined key words
        NoOfLamps
        LumensPerLamp
        CandelaMultiplier
        NoVertAngles
        NoHorizAngles
        PhotoType
        UnitsType
        Width
        Length
        Height
        BallastFactor
        FutureUse
        InputWatts
        VertAngles
        HorizAngles
        photoTable % photopic distribution Table
    end
    properties (Dependent)
        LengthFt
        WidthFt
    end
    methods
        %Constructor
        function ies= IESFile(path)
            if exist(path, 'file') && ~exist(path, 'dir')
                fid = fopen(fullfile(path));
                c = onCleanup(@() fclose(fid));
                match = 0;
                ies.Properties.More= [];
                while ~match
                    tline = fgetl(fid);
                    match = contains(tline,'TILT');
                    expression = '\[(\w+).*\]';
                    tokens = regexp(tline,expression,'tokens');
                    if ~isempty(tokens)
                        switch tokens{1}{1}
                            case 'TEST'
                                ies.Properties.Test = tline(length('[TEST]')+1:end);
                            case 'TESTLAB'
                                ies.Properties.TestLab = tline(length('[TESTLAB]')+1:end);
                            case 'ISSUEDATE'
                                ies.Properties.IssueDate = tline(length('[ISSUEDATE]')+1:end);
                            case'TESTDATE'
                                ies.Properties.TestDate = tline(length('[TESTDATE]')+1:end);
                            case 'MANUFAC'
                                ies.Properties.Manufacture = tline(length('[MANUFAC]')+1:end);
                            case 'LAMP'
                                ies.Properties.Lamp = tline(length('[LAMP]')+1:end);
                            case 'NEARFIELD'
                                ies.Properties.NearField = tline(length('[NEARFIELD]')+1:end);
                            case 'OTHER'
                                ies.Properties.Other = tline(length('[OTHER]')+1:end);
                            case 'LUMCAT'
                                ies.Properties.LumCat = tline(length('[LUMCAT]')+1:end);
                            case 'LAMPCAT'
                                ies.Properties.LampCat = tline(length('[LAMPCAT]')+1:end);
                            case 'LUMINAIRE'
                                ies.Properties.Luminaire = tline(length('[LUMINAIRE]')+1:end);
                            case 'BALLAST'
                                ies.Properties.Ballast = tline(length('[BALLAST]')+1:end);
                            case 'BALLASTCAT'
                                ies.Properties.BallastCat = tline(length('[BALLASTCAT]')+1:end);
                            case 'MAINTCAT'
                                ies.Properties.MaintCat = tline(length('[MAINTCAT]')+1:end);
                            case 'DISTRIBUTION'
                                ies.Properties.Distrubution = tline(length('[DISTRIBUTION]')+1:end);
                            case 'FLASHAREA'
                                ies.Properties.FlashArea = tline(length('[FLASHAREA]')+1:end);
                            case 'COLORCONSTANT'
                                ies.Properties.ColorConstant = tline(length('[COLORCONSTANT]')+1:end);
                            case 'LAMPPOSITION'
                                ies.Properties.LampPosition = tline(length('[LAMPPOSITION]')+1:end);
                            case 'SEARCH'
                                ies.Properties.Search = tline(length('[SEARCH]')+1:end);
                            case 'MORE'
                                if isempty(ies.Properties.More)
                                    ies.Properties.More{1} = tline(length('[MORE]')+1:end);
                                else
                                    ies.Properties.More{end} = tline(length('[MORE]')+1:end);
                                end
                            otherwise
                        end
                    end
                    if contains(tline,'TILT=NONE')
                        A = [];
                        while length(A)< 13
                            tline = fgetl(fid);
                            B = sscanf(tline,'%f');
                            A = [A;B];
                        end
                        ies.NoOfLamps = A(1);
                        ies.LumensPerLamp = A(2);
                        ies.CandelaMultiplier = A(3);
                        ies.NoVertAngles = A(4);
                        ies.NoHorizAngles = A(5);
                        ies.PhotoType = A(6);
                        ies.UnitsType = A(7);
                        if ies.UnitsType == 1
                            ies.Width = convlength( A(8),'ft','m');
                            ies.Length = convlength( A(9),'ft','m');
                        else
                            ies.Width = A(8);
                            ies.Length = A(9);
                        end
                        ies.Height = A(10);
                        ies.BallastFactor = A(11);
                        ies.FutureUse = A(12);
                        ies.InputWatts = A(13);
                        
                        while (length(A)<(13+ies.NoVertAngles+ies.NoHorizAngles+ies.NoVertAngles*ies.NoHorizAngles))
                            tline = fgetl(fid);
                            B = sscanf(tline,'%f');
                            A = [A;B];
                        end
                    end
                end
                ies.VertAngles = A(14:13+ies.NoVertAngles);
                ies.HorizAngles = A(14+ies.NoVertAngles:13+ies.NoVertAngles+ies.NoHorizAngles);
                Candelas = A(14+ies.NoVertAngles+ies.NoHorizAngles:end)*ies.CandelaMultiplier;
                
                % Get candela matrix
                ies.photoTable = zeros(ies.NoVertAngles,ies.NoHorizAngles);
                for i = 1:ies.NoHorizAngles
                    ies.photoTable(:,i) = Candelas((i-1)*ies.NoVertAngles+1:i*ies.NoVertAngles);
                end
                % Add a duplicate collum so it can loop around at 360==0
                if ies.HorizAngles(1) == 0
                    switch ies.HorizAngles(end)
                        % This determins the symmetry of the system.
                        case 0
                            ies.photoTable(:,end+1) = ies.photoTable(:,end);
                            ies.HorizAngles(end+1) = 360;
                            ies.NoHorizAngles = length(ies.HorizAngles);
                        case 90
                            
                        case 180
                            
                        case 360
                            %this is what we want
                        otherwise
                            error('IESFile s Last Horizontal Angle is not 0, 90, 180, or 360');
                            
                    end
                else
                    error('IESFile s first Horizontal Angle is not 0');
                end
                if ies.VertAngles(1) == 0
                    switch ies.VertAngles(end)
                        % This determins the symitry of the system.
                        case 90
                            skip = ies.VertAngles(end)-ies.VertAngles(end-1);
                            while ies.VertAngles(end)<180
                                ies.photoTable(end+1,:) = zeros(1,ies.NoHorizAngles);
                                ies.VertAngles(end+1) = ies.VertAngles(end)+skip;
                                ies.NoVertAngles = length(ies.VertAngles);
                            end
                        case 180
                            %this is what we want
                        otherwise
                            error('IESFile s Last Vertical Angle is not 90 or 180');
                            
                    end
                elseif ies.VertAngles(1) == 90
                else
                    error('IESFile s first Vertical Angle is not 0 or 90');
                end
                
            
            else
                error('File does not exist');
            end %file exists & not dir
        end
        function len = get.LengthFt(obj)
            len = unitsratio('ft','m') * obj.Length;
        end
        function wid = get.WidthFt(obj)
            wid = unitsratio('ft','m') * obj.Width;
        end
        function tf = eq(obj1,obj2)
            if strcmpi(class(obj1),class(obj2))
                tf(1) = all(all(obj1.photoTable==obj2.photoTable));
                tf(2) = all(obj1.VertAngles==obj2.VertAngles)&all(obj1.HorizAngles==obj2.HorizAngles);
                tf(2) = (obj1.Length==obj2.Length)&(obj1.Width==obj2.Width);
            else
                tf=false;
            end
            tf = all(tf);
        end
        
    end
end

