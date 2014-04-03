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
	%vx = zeros(h, w, N);
	%vy = zeros(h, w, N);
	disp('Loading data...');
	for i=1:N
		imgs(:,:,:,i) = imread([path d(i).name]);
    end
    
    imshow(im);
    p = ginput(2);
    bbox = [p(1,1), p(1,2), p(2,1)-p(1,1), p(2,2)-p(1,2)];
      
	savedRes = [];
    hold on
	disp('Start calculating flow...');
	pause;
	for i=2:N
        region = round([bbox(1)-0.25*bbox(3), bbox(2)-0.25*bbox(4), 1.5*bbox(3), 1.5*bbox(4)]);
        region = sanityCheck(region, w, h);
        im1 = imgs(:,:,:,i-1);
        im2 = imgs(:,:,:,i);
        im1_crop = im1(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1,:);
        im2_crop = im2(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1,:);
		tic;
		[flowx, flowy] = Coarse2FineTwoFrames(im1_crop, im2_crop, para);
		toc;
	    %flowx_mean = mean(mean(flowx));
        %flowy_mean = mean(mean(flowy));
        %net_flow_mag = sqrt((flowx-flowx_mean).^2+(flowy-flowy_mean).^2);
        
        fprintf('Process %d/%d frames\n', i-1, N-1);
        
        
        clf
        diff = bbox(1:2)-region(1:2)+1;
        flowx_bg = (sum(sum(flowx))-sum(sum(flowx(diff(2):diff(2)+bbox(4)-1,diff(1):diff(1)+bbox(3)-1))))/(region(3)*region(4)-bbox(3)*bbox(4));
        flowy_bg = (sum(sum(flowy))-sum(sum(flowy(diff(2):diff(2)+bbox(4)-1,diff(1):diff(1)+bbox(3)-1))))/(region(3)*region(4)-bbox(3)*bbox(4));
        
        net_flow_mag = zeros(h, w);
        net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1) = ...
            sqrt((flowx-repmat(flowx_bg,[region(4) region(3)])).^2+(flowy-repmat(flowy_bg,[region(4) region(3)])).^2);
        
        subplot(2,1,1);
        imagesc(net_flow_mag);
        %bboxS = reshape(net_flow_mag(bbox(2):bbox(2)+bbox(4)-1,bbox(1):bbox(1)+bbox(3)-1), bbox(3)*bbox(4),1);
        %bboxL = reshape(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1), region(3)*region(4),1);
        [clusters, C] = kmeans(reshape(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1), region(3)*region(4), 1), 2, 'start', 'uniform');
        clusters = reshape(clusters, region(4), region(3));
        [thres, c] = max(C);
        %sort_flow_mag = sort(bboxL,'descend');
        %cumSum = cumsum(sort_flow_mag)./sum(bboxL);
        %thres = sort_flow_mag(find(cumSum > .25, 1, 'first' ));
        [r, c] = find(clusters == c);
        x0 = min(c);
        x1 = max(c);
        y0 = min(r);
        y1 = max(r);
        %x0 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1))>thres, 1 );
        %x1 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1))>thres, 1, 'last' );
        %y0 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1),[],2)>thres, 1 );
        %y1 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1),[],2)>thres, 1, 'last' );
        
        subplot(2,1,2);
        imshow(im1);
        savedRes = [savedRes; bbox];
        bbox = [region(1)+x0, region(2)+y0, x1-x0, y1-y0];
        rectangle('Position', bbox, 'EdgeColor', 'g','LineWidth', 2.5);
        drawnow;
	end

	save([title '_track'], 'savedRes');
end