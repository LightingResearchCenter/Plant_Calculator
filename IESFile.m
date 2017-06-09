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
        photoTable % photopic distrobution Table
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
                        ies.Width = A(8);
                        ies.Length = A(9);
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
                if ies.HorizAngles(end) < 360
                    ies.photoTable = [ies.photoTable,ies.photoTable(:,1)];
                    ies.HorizAngles = [ies.HorizAngles;360];
                    ies.NoHorizAngles = ies.NoHorizAngles+1;
                end
            else
                error('File does not exist');
            end %file exists & not dir
        end
        %Methods
        
        
    end
end

