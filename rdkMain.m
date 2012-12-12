p = pathdef;
matlabpath(p);

sys = ObjSet.SysCheck;
exp = ObjSet.ExpSet(sys);
obj = ObjSet(sys,exp);
obj.batchDot;
save('test.mat','obj');
quit
% dot = obj.DotGen;
w = Screen('OpenWindow',1,0,[],[],[],4);
% dot = cell([3 1]);
% 
% for test = 1:3
%     if test == 1
%         j = batch('batchDot', 2, {obj},'matlabpool',1,'FileDependencies','ObjSet.m pathdef.m');
%     else
%         j = batch('batchDot', 2, {r{2}},'matlabpool',1,'FileDependencies','ObjSet.m pathdef.m');
%     end
%     wait(j);
%     r = getAllOutputArguments(j);
%     dot{test} = r{1};
% end
% 
for ii = 1
    for i = 1:600
        obj.exp.draw_fun(dot{10}(:,:,i,1)',w);
        obj.exp.selectstereo_fun(w,1);
        obj.exp.draw_fun(dot{10}(:,:,i,2)',w);
        pause(.03);
        obj.exp.flip_fun(w);
    end
end

% j = batch('batchDot', 2, {obj},'matlabpool',1,'FileDependencies','ObjSet.m pathdef.m');
% 
% x = get(j.Tasks);
% {x(:).State}
