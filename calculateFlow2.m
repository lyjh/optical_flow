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

	save('./result/' [title '_flow2'], 'vx', 'vy');
end

%{
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
    
    imshow(im);
    p = ginput(2);
    bbox = [p(1,1), p(1,2), p(2,1)-p(1,1), p(2,2)-p(1,2)];
      
	
    hold on
	disp('Start calculating flow...');
	for i=2:N
        region = round([bbox(1)-0.5*bbox(3), bbox(2)-0.5*bbox(4), 2*bbox(3), 2*bbox(4)]);
        region = sanityCheck(region, w, h);
        im1 = imgs(:,:,:,i-1);
        im2 = imgs(:,:,:,i);
        im1_crop = im1(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1,:);
        im2_crop = im2(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1,:);
		tic;
		[flowx, flowy] = Coarse2FineTwoFrames(im1_crop, im2_crop, para);
		toc;
	    
        
        fprintf('Process %d/%d frames\n', i-1, N-1);
        
        
        clf
        diff = bbox(1:2)-region(1:2)+1;
        flowx_bg = (sum(sum(flowx))-sum(sum(flowx(diff(2):diff(2)+bbox(4),diff(1):diff(1)+bbox(3)))))/(region(3)*region(4)-bbox(3)*bbox(4));
        flowy_bg = (sum(sum(flowy))-sum(sum(flowy(diff(2):diff(2)+bbox(4),diff(1):diff(1)+bbox(3)))))/(region(3)*region(4)-bbox(3)*bbox(4));
        
        net_flow_mag = zeros(h, w);
        net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1) = ...
            sqrt((flowx-repmat(flowx_bg,[region(4) region(3)])).^2+(flowy-repmat(flowy_bg,[region(4) region(3)])).^2);
        
        imagesc(net_flow_mag);
        res = reshape(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1), region(3)*region(4),1);
        sort_flow_mag = sort(res,'descend');
        cumSum = cumsum(sort_flow_mag)./sum(res);
        thres = sort_flow_mag(find(cumSum > .25, 1, 'first' ));
        x0 = find(max(net_flow_mag)>thres, 1 );
        x1 = find(max(net_flow_mag)>thres, 1, 'last' );
        y0 = find(max(net_flow_mag,[],2)>thres, 1 );
        y1 = find(max(net_flow_mag,[],2)>thres, 1, 'last' );
        bbox = [x0, y0, x1-x0, y1-y0];
        drawnow;
	end

	save([title '_flow2'], 'vx', 'vy');
end
%}