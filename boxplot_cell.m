function boxplot_cell(celldata, pars)
%celldata should be a nested cell array structure. celldata{i} includes the
%information of the i-th graoup. so groupdata = celldata{i} is another cell
%array. groupdata{j} includes the j-th set in the i-th group. setdata =
%groupdata{j} is an array whose statistics determine the corresponding box.
%Every setdata will generate one box.

%pars.position, the center position of each group, this also sets the x
%range limits. Default is [1, 2, 3...]

%pars.intragroupspacing, the space between nearby box in the same group,
%measured from the adjacent box centers. In units of xrange.

%pars.boxwidth, the width of every box. Default is intraspacing/3

%pars.linecolors, a cell array of the structure of 
%{{c1a c1b..},{c2a c2b c3c..}..}, sets the color of the box boundary, the 
%line of mean value and the whiskers, default is black. The format can be
%two types: {'k','r',{[1,0,0]}...} which sets the color of each group. Or it
%can be {{'k','r','k'},{'r','b'}...}, which sets teh color of each box.
%Notice that in the later case, there must be enough entries for each box.
%The input can be a mix of both format for diffferent groups.

%pars.boxcolors, a cell array of the structyure similar to the linecolors,
%sets the color of the box filled colors. Default is red.

%pars.linewidths, width of lines for [mean, box edge, whiskers]

%pars.quantile, set the cutting cumulative probability to plot the box and
%whiskers. Defaut [0.05,0.25,0.75,0.95];

%example 1:
%celldata = {{randn(1,20)},{randn(1,10),randn(1,30)},{randn(1,100)}};
%pars = 0;
%boxplot_cell(celldata, pars)

%example 2:
%celldata = {{randn(1,20)},{randn(1,10),randn(1,30)},{randn(1,100)}};
%pars = 0;
%pars.boxcolors = {'b','m',{[1,0,0]}};
%pars.linecolors = {'k',{[1,1,0],[1,0,1]},'r'};
%boxplot_cell(celldata, pars)


%example 3:
%celldata = {{randn(1,20)},{randn(1,10),randn(1,30)},{randn(1,100)}};
%pars = 0;
%pars.boxcolors = {'b','m',{[1,0,0]}};
%pars.linecolors = {'k',{[1,1,0],[1,0,1]},'r'};
%pars.linewidths = [3,1,2];
%pars.boxwidth = 0.3;
%pars.position = [1,2,5];
%boxplot_cell(celldata, pars)
%ylim([-3,3]);

%Written by Bo Sun, Department of Physics, Oregon State University
%Oct. 21th 2014


ngroup = length(celldata);
nsets = zeros(1,ngroup);
groupcenters = zeros(1,ngroup);
for i = 1:ngroup
    nsets(i) = length(celldata{i});
    groupcenters(i) = i;
end

if(isfield(pars,'position'))
    groupcenters = pars.position;
end
%default box spacing
intraspacing = ...
    min(groupcenters(2:end)-groupcenters(1:end-1))/(max(nsets)+1);

if(isfield(pars,'intragroupspacing'))
    intraspacing = pars.intragroupspacing;
end


%now determine the center of each box
boxcenters = zeros(1,1);
for i = 1:ngroup
    for j = 1:nsets(i)        
        boxcenters(i,j) = groupcenters(i)+(j-1)*intraspacing...
            -(nsets(i)-1)/2*intraspacing;        
    end
end

%default box width
boxwidth = intraspacing/3;

if(isfield(pars,'boxwidth'))
    boxwidth = pars.boxwidth;
end

%default line widths
linewidths = [2,1,1];

if(isfield(pars,'linewidths'))    
    linewidths = pars.linewidths;
end

%default box colors and line colors
boxcolors = {'r'};
linecolors = {'k'};

for i = 1:ngroup
    for j = 1:nsets(i)
        boxcolors{i,j} = 'r';
        linecolors{i,j} = 'k';
    end
    
    if(isfield(pars,'linecolors'))
        temp = pars.linecolors;
        tempcolori = temp{i};
        for j = 1:nsets(i)
            if(length(tempcolori) == 1)                
                linecolors{i,j} = tempcolori;
            else
                linecolors{i,j} = tempcolori{j};
            end
        end        
    end
    
    if(isfield(pars,'boxcolors'))
        temp = pars.boxcolors;
        tempcolori = temp{i};
        for j = 1:nsets(i)
            if(length(tempcolori) == 1)                
                boxcolors{i,j} = tempcolori;
            else
                boxcolors{i,j} = tempcolori{j};
            end
        end        
    end
    %to expand the rgb into 3x1 array rather than hide in a cell
    for j = 1:nsets(i)
        p = boxcolors{i,j};
        if(iscell(p))
            boxcolors{i,j} = p{1};
        end
        
        p = linecolors{i,j};
        if(iscell(p))
            linecolors{i,j} = p{1};
        end
          
        
    end
        
end

boxquantile = [0.05,0.25,0.75,0.95];
if(isfield(pars,'quantile'))
    boxquantile = pars.quantile;
end

%now plotting each box based on the parameters.

for i = 1:ngroup   
    groupdata = celldata{i};
    for j = 1:nsets(i)
        setdata = groupdata{j};
        xc = boxcenters(i,j);
        xl = xc-boxwidth/2;
        xr = xc+boxwidth/2;
        temp = quantile(setdata,boxquantile);
        ybt = temp(3);
        ybb = temp(2);
        ywb = temp(1);
        ywt = temp(4);
        xtemp = [xl,xl,xr,xr];
        ytemp = [ybb,ybt,ybt,ybb];
        %the box;
        hpatch = patch(xtemp,ytemp,'r');
        hold on;
        set(hpatch,'LineWidth',linewidths(2),'EdgeColor',linecolors{i,j},...
            'FaceColor',boxcolors{i,j});
        %horizontal line of mean
        hmean = plot([xl,xr],[mean(setdata),mean(setdata)]);
        set(hmean,'LineWidth',linewidths(1),'Color',linecolors{i,j});
        %vertical line of whisker
        plot([xc,xc],[ybb,ywb],'LineWidth',linewidths(3),...
            'Color',linecolors{i,j});        
        plot([xc,xc],[ybt,ywt],'LineWidth',linewidths(3),...
            'Color',linecolors{i,j});
        %horizontal line of whisker
        plot([xl,xr],[ywb,ywb],'LineWidth',linewidths(3),...
            'Color',linecolors{i,j});        
        plot([xl,xr],[ywt,ywt],'LineWidth',linewidths(3),...
            'Color',linecolors{i,j});
        
        
        
        
    end
end

end






%now we will generate the line



%determin the total x axis range
