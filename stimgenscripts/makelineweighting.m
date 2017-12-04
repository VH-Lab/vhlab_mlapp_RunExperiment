function [tunescript, offs] = makelineweighting(base, offsets, signs, tlength, width, duration)

%  MAKELINEWEIGHTING - Makes line weighting stimulus
%
%   [TUNESCRIPT, POSITIONS] = MAKELINEWEIGHTING(BASE, OFFSETS,...
%      SIGNS, LENGTH, WIDTH, DURATION)
%
%  Creates a STIMSCRIPT with PERIODICSTIM elements for measuring responses
%  to small lines.  BASE is a PERIODICSTIM that provides all parameter
%  values except the offsets and width.  LENGTH is the desired line length
%  (in pixels), and WIDTH is the desired width (in pixels).
%  OFFSETS is a row vector of offsets from the center location (in pixels).
%  These offsets will translated so they are perpendicular to the cell's
%  preferred orientation.

%
%  All periodicstim stimuli will be 'angled rects', regardless of what
%  is set in BASE.
%
%  TUNESCRIPT will be a stimscript that has all combinations of the
%  elements in LENGTH and WIDTH.  The Nth row of the matrix LENGTHWIDTH
%  contains the length and width used in the Nth stimulus in TUNESCRIPT.

p = getparameters(base);

x_ = mean(p.rect([1 3])); y_ = mean(p.rect([2 4]));

tunescript = stimscript(0); lengthwidth = [];

p.windowShape = 2;
p.imageType = 0;  % field
p.animType = 0;   % static
p.nCycles = 1;
p.tFrequency = 1/duration;

ang = -p.angle * pi/180;

offs = [offsets' zeros(size(offsets'))] * [cos(ang+pi/2) -sin(ang+pi/2); sin(ang+pi/2) cos(ang+pi/2) ];

myrects = [];
lineno = 1;

for i=1:length(signs),
	if signs(i)==-1,
		p.flickerType = 1;
	elseif signs(i)==1,
		p.flickerType = 0;
	end;
	for j=1:length(offsets),
		p.lineoffset = offsets(j);
		p.linenumber = lineno;
		lineno = lineno + 1;
		p.rect=round([x_+offs(j,1)-tlength/2 y_+offs(j,2)-width/2 x_+offs(j,1)+tlength/2 y_+offs(j,2)+width/2]);
		tunescript = append(tunescript,periodicstim(p));
		myrects = cat(1,myrects,p.rect);
	end;
end;

if 0,
figure
for i=1:size(myrects),
	ml=myrects(i,:);
	ctr = [mean(ml([1 3])) mean(ml([2 4]))];
	mypts = [[ml([1 3 3 1])]' [ml([2 2 4 4])]'];
	mypts(:,1) = mypts(:,1) - ctr(1); mypts(:,2) = mypts(:,2) - ctr(2);
	mypts = mypts * [cos(ang) -sin(ang); sin(ang) cos(ang)];
	mypts(:,1) = mypts(:,1) + ctr(1); mypts(:,2) = mypts(:,2) + ctr(2);
	patch(mypts(:,1),mypts(:,2),[0.5 0.5 0.5]);
end;
end;
