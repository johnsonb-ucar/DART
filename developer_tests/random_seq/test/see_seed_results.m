flist = { ...
'uniform_baseline' ...
'uniform_0001dt_01h' ...
'uniform_0010dt_01h' ...
'uniform_0010dt_06h' ...
'uniform_0100dt_06h' ...
'uniform_0010dt_12h' ...
'uniform_0100dt_12h' ...
'uniform_0100dt_24h' ...
'uniform_1000dt_24h' ...
'uniform_0001dt_0001y' ...
'uniform_0100dt_0010y' ...
'gaussian_baseline' ...
'gaussian_0001dt_01h' ...
'gaussian_0010dt_01h' ...
'gaussian_0010dt_06h' ...
'gaussian_0100dt_06h' ...
'gaussian_0010dt_12h' ...
'gaussian_0100dt_12h' ...
'gaussian_0100dt_24h' ...
'gaussian_1000dt_24h' ...
'gaussian_0001dt_0001y' ...
'gaussian_0100dt_0010y' };


for i = 1:length(flist)

  x=load(flist{i});
  histogram(x, 100);
  title(flist{i},'Interpreter','none');
  disp('hit enter to continue')
  pause; 

end
