function [] = viewResult(title)
	dataPath = '../Dataset/';
	addpath('drawUtility');

	fullPath = [dataPath, title, '/img/'];
	%fullPath = [dataPath, '/' 'img/'];
	d = dir([fullPath, '*.jpg']);
	if size(d, 1) == 0
		d = dir([fullPath, '*.png']);
	end
	if size(d, 1) == 0
		d = dir([fullPath, '*.bmp']);
	end
	im = imread([fullPath, d(1).name]);

	% Load data
	disp('Loading data...');
	data = zeros(size(im, 1), size(im, 2), 3, size(d, 1));
	for i = 1 : size(d, 1)
		data(:, :, :, i) = imread([fullPath, d(i).name]);
	end
	load([title '_track.mat']);
	for i = 1:size(d, 1)
		frame = data(:,:,:,i);
		imshow(frame);
		hold on
		drawTrackRst(frame, savedRes(i,:));
	end
end

function [] = drawTrackRst(frame, bbox);
	% input - frame: normalized frame [0, 1]
	%       - param: affine matrix  
	clf
    imshow(uint8(frame));
	%bbox = param2bbox(param, size(frame), [227, 227]);   % get bbox
	rectangle('Position', [bbox(1:4)], 'LineWidth', 2.5, 'EdgeColor', 'r');
	drawnow;
end