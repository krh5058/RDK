sys = ObjSet.SysCheck;
exp = ObjSet.ExpSet(sys);
obj = ObjSet(sys,exp);
dot = obj.DotGen;
w = Screen('OpenWindow',1,0,[],[],[],4);
for i = 1:60;obj.exp.draw_fun(dot(:,:,i,1)',w);obj.exp.selectstereo_fun(w,1);obj.exp.draw_fun(dot(:,:,i,2)',w);obj.exp.flip_fun(w);end;

% j = batch('testhi', 2, {obj},'matlabpool',1,'FileDependencies','ObjSet.m pathdef.m');
% 
% x = get(j.Tasks);
% {x(:).State}
% r = getAllOutputArguments(j);