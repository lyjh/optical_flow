function [] = calculateFlow2(title)
	addpath('mex');
	path = ['../Dataset/' title '/img/'];
	d = dir([path '*.jpg']);
	N = size(d,1);
	
	alpha = 0.012;
	ratio = 0.75;
	minWidth = 20;
	nOuterFPIterations = 7;
	nInnerFPIterations = 1;
	nSORIterations = 30;

	para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
	
	im = imread([path d(1).name]);
	[h, w, c] = size(im);
	imgs = zeros([h, w, c, N], 'uint8');
	vx = zeros(h, w, N);
	vy = zeros(h, w, N);
	disp('Loading data...');
	for i=1:N
		imgs(:,:,:,i) = imread([path d(i).name]);
	end

	disp('Start calculating flow...');
	for i=2:N
		tic;
		[vx(:,:,i), vy(:,:,i)] = Coarse2FineTwoFrames(imgs(:,:,:,i-1), imgs(:,:,:,i), para);
		toc;
	    fprintf('Process %d/%d frames\n', i-1, N-1);
	end

	save([title '_flow2'], 'vx', 'vy');
end