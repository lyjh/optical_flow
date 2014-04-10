function [] = calculateFlow2(title)
    addpath('mex');
	path = ['../Dataset/' title '/img/'];
	d = dir([path '*.jpg']);
	N = size(d,1);

	%% parameters for optical flow
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
	close
	figure
    hold on
	disp('Start calculating flow...');
	for i=2:N
		%% crop a region that is slightly larger than the current bounding box
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
        diff = bbox(1:2)-round(region(1:2))+1;
		%% flow that is outside the bounding box, but within the larger region
        flowx_bg = (sum(sum(flowx))-sum(sum(flowx(diff(2):diff(2)+bbox(4)-1,diff(1):diff(1)+bbox(3)-1))))/(region(3)*region(4)-bbox(3)*bbox(4));
        flowy_bg = (sum(sum(flowy))-sum(sum(flowy(diff(2):diff(2)+bbox(4)-1,diff(1):diff(1)+bbox(3)-1))))/(region(3)*region(4)-bbox(3)*bbox(4));
        
        net_flow_mag = zeros(h, w);
        net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1) = ...
            sqrt((flowx-repmat(flowx_bg,[region(4) region(3)])).^2+(flowy-repmat(flowy_bg,[region(4) region(3)])).^2);
        
        subplot(2,1,1);
        imagesc(net_flow_mag);
        %bboxS = reshape(net_flow_mag(bbox(2):bbox(2)+bbox(4)-1,bbox(1):bbox(1)+bbox(3)-1), bbox(3)*bbox(4),1);
        %bboxL = reshape(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1), region(3)*region(4),1);
		%% use k-means clustering to differentiate background and foreground
        [clusters, C] = kmeans(reshape(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1), region(3)*region(4), 1), 2, 'start', 'uniform');
        clusters = reshape(clusters, region(4), region(3));
        [thres, k] = max(C);
        %sort_flow_mag = sort(bboxL,'descend');
        %cumSum = cumsum(sort_flow_mag)./sum(bboxL);
        %thres = sort_flow_mag(find(cumSum > .25, 1, 'first' ));
		%% get bounding box that surround the foreground
        [r, c] = find(clusters == k);
        x0 = min(c);
        x1 = max(c);
        y0 = min(r);
        y1 = max(r);
		rectangle('Position', [region(1)+x0 ,region(2)+y0, x1-x0, y1-y0], 'EdgeColor', 'r','LineWidth', 2.5);
        mask = clusters == k;

        flowx_fg = flowx(y0:y1, x0:x1) .* mask(y0:y1, x0:x1);
        flowy_fg = flowy(y0:y1, x0:x1) .* mask(y0:y1, x0:x1);
		[TL, TR, BL, BR] = updateCorners(flowx_fg, flowy_fg);
        %{
		o = [round(y1/2), round(x1/2)];
        TL = [sum(sum(flowx_fg(1:o(1), 1:o(2))))/nnz(flowx_fg(1:o(1), 1:o(2))), sum(sum(flowy_fg(1:o(1), 1:o(2))))/nnz(flowy_fg(1:o(1), 1:o(2)))];
        TR = [sum(sum(flowx_fg(1:o(1), o(2)+1:end)))/nnz(flowx_fg(1:o(1), o(2)+1:end)), sum(sum(flowy_fg(1:o(1), o(2)+1:end)))/nnz(flowy_fg(1:o(1), o(2)+1:end))];
        BL = [sum(sum(flowx_fg(o(1)+1:end, 1:o(2))))/nnz(flowx_fg(o(1)+1:end, 1:o(2))), sum(sum(flowy_fg(o(1)+1:end, 1:o(2))))/nnz(flowy_fg(o(1)+1:end, 1:o(2)))];
        BR = [sum(sum(flowx_fg(o(1)+1:end, o(2)+1:end)))/nnz(flowx_fg(o(1)+1:end, o(2)+1:end)), sum(sum(flowy_fg(o(1)+1:end, o(2)+1:end)))/nnz(flowy_fg(o(1)+1:end, o(2)+1:end))];
		%}
        xx0 = bbox(1)+min(TL(1), BL(1));
        xx1 = bbox(1)+bbox(3)+max(TR(1), BR(1));
        yy0 = bbox(2)+min(TL(2), TR(2));
        yy1 = bbox(2)+bbox(4)+max(BL(2), BR(2));
        bbox = round(sanityCheck([xx0, yy0, xx1-xx0, yy1-yy0], w, h));
        %x0 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1))>thres, 1 );
        %x1 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1))>thres, 1, 'last' );
        %y0 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1),[],2)>thres, 1 );
        %y1 = find(max(net_flow_mag(region(2):region(2)+region(4)-1, region(1):region(1)+region(3)-1),[],2)>thres, 1, 'last' );
        
        subplot(2,1,2);
        imshow(im1);
        savedRes = [savedRes; bbox];
        %bbox = [region(1)+x0-1, region(2)+y0-1, x1-x0, y1-y0];
        rectangle('Position', bbox, 'EdgeColor', 'g','LineWidth', 2.5);
        drawnow;
	end

	save([title '_track'], 'savedRes');
end