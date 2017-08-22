h1 = plot(1:10, rand(2,10));
lgnd = legend('show');
axe = gca;
h2 = figure;
axe2 = axes(h2);
lgnd2 = legend(axe2,[h1],lgnd.String{:});
axe2.Visible= 'off';

fn = 'plot';%filename
l = 1:length(fn);
fn = sprintf('%s_LEGEND',fn(l));%give it a separate filename

a = get(gcf,'children');% link to ledgend is now a(1)
b = get(gca,'children');% link to the data curve/s
set(a(1),'AutoUpdate','off');
set(a(2),'visible','off'); %hide axes etc...
set(b,'visible','off'); %hide data...

legfs = get(a(1),'Fontsize'); %get legend fontsize
set(a(1),'Fontsize',legfs+1); %make legend appear larger

%... print it...

%reset everything to notmal plot:
set(a,'visible','on');
set(b,'visible','on');
fn = fn(l);
set(a(1),'visible','off'); %hide only legend from plot