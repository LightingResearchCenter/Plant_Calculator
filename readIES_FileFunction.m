function [Intensity,thetas,phis] = readIES_FileFunction(filePathName)
%fileName = 'UVBFixture2Trace.ies'; %'UVBFixture2Trace.ies'; %'UVBFixtureNoReflTrace.ies'; % 'UVB1b.ies';


fid = fopen(filePathName,'r');
tiltLine = 0;
while ~tiltLine
%for loop = 1:11
    fileLine = fgetl(fid);
    if length(fileLine>=4)
        tiltLine = strcmp(fileLine(1:4),'TILT');
    end
end
fileLine = fgetl(fid);
A = sscanf(fileLine,'%f%f%f%f%f');
numTheta = A(4);
numPhi = A(5);
for loop = 1:2
    fileLine = fgetl(fid);
end
thetas = sscanf(fileLine,'%f');
while length(thetas)<numTheta
    fileLine = fgetl(fid); % read values continued on next line
    thetas = [thetas;sscanf(fileLine,'%f')];
end
fileLine = fgetl(fid); % read first line of phi (azimuthal) values
phis = sscanf(fileLine,'%f');
while length(phis)<numPhi
    fileLine = fgetl(fid); % read values continued on next line
    phis = [phis;sscanf(fileLine,'%f')];
end

% Read array of intensity values
I = zeros(numTheta,numPhi);
for i1 = 1:numPhi
    fileLine = fgetl(fid);
    a = sscanf(fileLine,'%f');
    while length(a)<numTheta
        fileLine = fgetl(fid); % read values continued on next line
        a = [a;sscanf(fileLine,'%f')];
    end
    I(1:length(a),i1) = a;
end
fclose(fid);
Intensity = I;
%I = I/I(1,1)*nadirLux*Distance^2; % calibrate intensity in cd 
%{
% Plot
%thetaRad = thetas*pi/180;
%polar(thetaRad,I(:,1))

% Plot
A = I;
Phi = phis;
Theta = thetas;
A = A(find(Theta>=0,1,'first'):find(Theta<thetaLimit,1,'last'),find(Phi>=0,1,'first'):find(Phi<360,1,'last'));
A = A/max(max(A)); % normalize data (for relative plots)
Phi = Phi(find(Phi>=0,1,'first'):find(Phi<360,1,'last'));
Theta = Theta(find(Theta>=0,1,'first'):find(Theta<thetaLimit,1,'last'));

Aplot = [A,A(:,1)]; %add first column(0 deg) to end (360 deg) so plotting draws complete picture
Phi = [Phi;Phi(1)];

ni = length(Theta);
nj = length(Phi);
z = zeros(ni,nj);
x = zeros(ni,nj);
y = zeros(ni,nj);

for i = 1:ni
   for j = 1:nj
      z(i,j) = Aplot(i,j)*cos(Theta(i)*pi/180);
      x(i,j) = Aplot(i,j)*sin(Theta(i)*pi/180)*cos(Phi(j)*pi/180);
      y(i,j) = Aplot(i,j)*sin(Theta(i)*pi/180)*sin(Phi(j)*pi/180);
   end
end

%Default View
figure(5)
h = surf(x,y,-z);
colormap([1 0 0])
%colormap([1 .3 .3])
axis equal
light('Position',[.5 1 .5])
light('Position',[.5 -1 .5])
material shiny
set(h,'AmbientStrength',.4,'FaceLighting','phong','DiffuseStrength' ,.5)
set(h,'SpecularStrength',1,'EdgeColor','none','FaceColor','interp','BackFaceLighting','lit')
%axis vis3d off
%axis([-1 1 -1 1 -1 .2])
view(142.5,30)
xlabel('x');ylabel('y');zlabel('z');
axis equal

% Polar Plot
Amax = A(1,1); %max(max(A))
A = A/Amax;
[rows,columns] = size(A);
cutsToPlot = [1,18;9,27]; % Specify the columns to plot. Rows specify cuts that are 180 degrees apart
lineTypes = {'b-','c-','g-','k-'};
theta = [(flipud(-Theta(2:end)));Theta];
rho = zeros(2*rows-1,size(cutsToPlot,1));
for i1 = 1:size(cutsToPlot,1)
    rho(:,i1) = [flipud((A(2:end,cutsToPlot(i1,2))));(A(:,cutsToPlot(i1,1)))];
    x = rho(:,i1) .* cos(theta*pi/180);
    y = rho(:,i1) .* sin(theta*pi/180);
    figure(1)
    hold on
    plot(y,-x,lineTypes{i1},'LineWidth',2); %  (y,-x) to rotate -90 degrees
    hold off
end
axis equal
%axis([-1 1 -1 .2])
%
hold on
% plot cosine response
x = cos(theta*pi/180) .* cos(theta*pi/180);
y = cos(theta*pi/180) .* sin(theta*pi/180);
figure(1)
h = plot(y,-x,'r--'); % x,y swapped to rotate -90 degrees
legend('0 deg','90 deg','cosine dist.')
set(gca,'FontSize',12)


% *** draw scale ***
for i = 1:5
	s1 =  0.2*i;
	u1 = s1 .* cos(theta*pi/180);
	v1 = s1 .* sin(theta*pi/180);
   h2 = plot(v1,-u1,'k:');
   set(h2,'LineWidth',.25)
end
plot([-1 0 1],[0 0 0],'k') %x-axis
plot([0 0],[0 -1.2],'k:') %y-axis
plot([0 -cos(30*pi/180)],[0 -sin(30*pi/180)],'k:') % gridline
plot([0 -cos(60*pi/180)],[0 -sin(60*pi/180)],'k:') % gridline
plot([0 cos(60*pi/180)],[0 -sin(60*pi/180)],'k:') % gridline
plot([0 cos(30*pi/180)],[0 -sin(30*pi/180)],'k:') % gridline
axis off
ht1 = text(0.05,-1.1,[num2str(max(max(I)),'%.1f') ' cd']);
set(ht1,'FontSize',14);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plotting horizontal cross sections(rho,theta 0 to 360) at different elevation angles(phi)
figure(2)
matrixRow = 10/2+1;%matrix has data every 2 degrees starting at 0 degrees
rho = [a(matrixRow,:) a(matrixRow,1)];
theta = 0:30:360;
theta = theta * pi/180;% convert to radians
x = rho .* (cos(theta));
y = rho .* (sin(theta));
h = plot(x,y,'k');
axis equal
axis([-1 1 -1 1])
set(h,'LineWidth',2)
hold on

matrixRow = 20/2+1;
rho = [a(matrixRow,:) a(matrixRow,1)];
theta = 0:30:360;
theta = theta * pi/180;% convert to radians
x = rho .* (cos(theta));
y = rho .* (sin(theta));
h = plot(x,y,'b');
axis equal
axis([-1 1 -1 1])
set(h,'LineWidth',2)
   
matrixRow = 30/2+1;
rho = [a(matrixRow,:) a(matrixRow,1)];
theta = 0:30:360;
theta = theta * pi/180;% convert to radians
x = rho .* (cos(theta));
y = rho .* (sin(theta));
h = plot(x,y,'c');
axis equal
axis([-1 1 -1 1])
set(h,'LineWidth',2)

matrixRow = 60/2+1;
rho = [a(matrixRow,:) a(matrixRow,1)];
theta = 0:30:360;
theta = theta * pi/180;% convert to radians
x = rho .* (cos(theta));
y = rho .* (sin(theta));
h = plot(x,y,'m');
axis equal
axis([-1 1 -1 1])
set(h,'LineWidth',2)
legend('10 deg','20 deg','30 deg','60 deg')

% *** draw scale ***
for i = 1:5
	s1 =  0.2*i;
	u1 = s1 .* cos(theta);
	v1 = s1 .* sin(theta);
   h2 = plot(u1,v1,'k:');
   set(h2,'LineWidth',.25)
end
plot([-1 0 1],[0 0 0],'k') %x-axis
plot([0 0 0],[1 0 -1],'k:') %y-axis
plot([0 cos(30*pi/180)],[0 sin(30*pi/180)],'k:') % gridline
plot([0 cos(60*pi/180)],[0 sin(60*pi/180)],'k:') % gridline
plot([0 cos(120*pi/180)],[0 sin(120*pi/180)],'k:') % gridline
plot([0 cos(150*pi/180)],[0 sin(150*pi/180)],'k:') % gridline
plot([0 cos(210*pi/180)],[0 sin(210*pi/180)],'k:') % gridline
plot([0 cos(240*pi/180)],[0 sin(240*pi/180)],'k:') % gridline
plot([0 cos(300*pi/180)],[0 sin(300*pi/180)],'k:') % gridline
plot([0 cos(330*pi/180)],[0 sin(330*pi/180)],'k:') % gridline
axis off

%}
