function [] = calculateFlow(title)
	path = ['../Dataset/' title '/img/'];
	d = dir([path '*.jpg']);
	N = size(d,1);
	im = imread([path d(1).name]);
	sz = size(im);
	imgs = zeros([sz, N]);
	uv = zeros([sz(1:2), 2, N]);
	disp('Loading data...');
	for i=1:N
		imgs(:,:,:,i) = imread([path d(i).name]);
	end

	disp('Start calculating flow...');
	for i=2:N
		tic;
		uv(:,:,:,i) = estimate_flow_interface(imgs(:,:,:,i-1), imgs(:,:,:,i));
		toc;
	   fprintf('Process %d/%d frames', i, N-1);
	end

	save([title '_flow'], 'uv');
end