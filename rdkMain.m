sys = ObjSet.SysCheck;
exp = ObjSet.ExpSet(sys);
obj = ObjSet(sys,exp);

% j = batch('testhi', 2, {obj},'matlabpool',1,'FileDependencies','ObjSet.m pathdef.m');
% 
% x = get(j.Tasks);
% {x(:).State}
% r = getAllOutputArguments(j);