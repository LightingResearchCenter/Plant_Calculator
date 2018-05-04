import mlreportgen.dom.*;
doctype = 'html';
d = Document('test',doctype);
d.Tag = 'My report';
     
dispatcher = MessageDispatcher.getTheDispatcher;
l = addlistener(dispatcher,'Message', ...
      @(src, evtdata) disp(evtdata.Message.formatAsHTML));
     
open(d);
dispatch(dispatcher, ProgressMessage('starting chapter',d));
p = Paragraph('Chapter ');
p.Tag = 'chapter title';
p.Style = { CounterInc('chapter'),...
   CounterReset('table'),WhiteSpace('pre') };
append(p,AutoNumber('chapter'));
append(d,p);

close(d);
rptview('test',doctype);
     
delete (l);