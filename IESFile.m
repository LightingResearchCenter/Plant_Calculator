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
                onCleanup(@() fclose(fid));
                match = 0;
                ies.Properties.More= [];
                while ~match
                    tline = fgetl(fid);
                    match = contains(tline,'TILT');
                    if contains(tline,'[TEST]')
                        ies.Properties.Test = tline(length('[TEST]')+1:end);
                    end
                    if contains(tline,'[TESTLAB]')
                        ies.Properties.TestLab = tline(length('[TESTLAB]')+1:end);
                    end
                    if contains(tline,'[ISSUEDATE]')
                        ies.Properties.IssueDate = tline(length('[ISSUEDATE]')+1:end);
                    end
                    if contains(tline,'[TESTDATE]')
                        ies.Properties.TestDate = tline(length('[TESTDATE]')+1:end);
                    end
                    if contains(tline,'[MANUFAC]')
                        ies.Properties.Manufacture = tline(length('[MANUFAC]')+1:end);
                    end
                    if contains(tline,'[LAMP]')
                        ies.Properties.Lamp = tline(length('[LAMP]')+1:end);
                    end
                    if contains(tline,'[NEARFIELD]')
                        ies.Properties.NearField = tline(length('[NEARFIELD]')+1:end);
                    end
                    if contains(tline,'[OTHER]')
                        ies.Properties.Other = tline(length('[OTHER]')+1:end);
                    end
                    if contains(tline,'[LUMCAT]')
                        ies.Properties.LumCat = tline(length('[LUMCAT]')+1:end);
                    end
                    if contains(tline,'[LAMPCAT]')
                        ies.Properties.LampCat = tline(length('[LAMPCAT]')+1:end);
                    end
                    if contains(tline,'[LUMINAIRE]')
                        ies.Properties.Luminaire = tline(length('[LUMINAIRE]')+1:end);
                    end
                    if contains(tline,'[BALLAST]')
                        ies.Properties.Ballast = tline(length('[BALLAST]')+1:end);
                    end
                    if contains(tline,'[BALLASTCAT]')
                        ies.Properties.BallastCat = tline(length('[BALLASTCAT]')+1:end);
                    end
                    if contains(tline,'[MAINTCAT]')
                        ies.Properties.MaintCat = tline(length('[MAINTCAT]')+1:end);
                    end
                    if contains(tline,'[DISTRIBUTION]')
                        ies.Properties.Distrubution = tline(length('[DISTRIBUTION]')+1:end);
                    end
                    if contains(tline,'[FLASHAREA]')
                        ies.Properties.FlashArea = tline(length('[FLASHAREA]')+1:end);
                    end
                    if contains(tline,'[COLORCONSTANT]')
                        ies.Properties.ColorConstant = tline(length('[COLORCONSTANT]')+1:end);
                    end
                    if contains(tline,'[LAMPPOSITION]')
                        ies.Properties.LampPosition = tline(length('[LAMPPOSITION]')+1:end);
                    end
                    if contains(tline,'[SEARCH]')
                        ies.Properties.Search = tline(length('[SEARCH]')+1:end);
                    end
                    if contains(tline,'[MORE]')
                        if isempty(ies.Properties.More)
                            ies.Properties.More{1} = tline(length('[MORE]')+1:end);
                        else
                            ies.Properties.More{end} = tline(length('[MORE]')+1:end);
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
                %TODO see if this is the proper way of generating this file
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
                
%                 if ies.HorizAngles(end) < 360
%                     ies.photoTable = [ies.photoTable,ies.photoTable(:,1)];
%                     ies.HorizAngles = [ies.HorizAngles;360];
%                     ies.NoHorizAngles = ies.NoHorizAngles+1;
%                 end
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
        
        
    end
end

