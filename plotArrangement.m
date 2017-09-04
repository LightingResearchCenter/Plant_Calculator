function plotArrangement(fixtureCenters, fixtureLength,fixtureWidth, roomLength,roomWidth)
figure;
rectangle('Position',[0,0,roomWidth,roomLength]);
axis(gca,'equal');
hold on
for i = 1:size(fixtureCenters,1)
    plot(fixtureCenters(i,1),fixtureCenters(i,2),'*');
    
end
hold off
end