import mlreportgen.dom.*;
d = Document('test');
input1 = CustomElement('input');
input1.CustomAttributes = {
 CustomAttribute('type', 'checkbox'), ...
 CustomAttribute('name', 'vehicle'), ...
 CustomAttribute('value', 'Bike'), ...
 };
append(input1, Text('I have a bike'));
ol = OrderedList({input1});
append(d,ol);
close(d);
rptview('test','html');