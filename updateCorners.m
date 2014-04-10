function [TL, TR, BL, BR] = updateCorners(flowx, flowy)
	% divide rectangle into 4 part, and calculate the mean flow of foreground in each part
	% output - corners: 4 x 2, corners(i) = [mean_flowx, meanflowy]
	% input -  flowx, flowy: flow within a tight rectangle, flowx(i, j) == 0 indicates that (i, j) is background
	[h, w] = size(flowx);
	c = round([h/2, w/2]);
	TL = [sum(sum(flowx(1:c(1), 1:c(2))))/nnz(flowx(1:c(1), 1:c(2))), sum(sum(flowy(1:c(1), 1:c(2))))/nnz(flowy(1:c(1), 1:c(2)))];
	TR = [sum(sum(flowx(1:c(1), c(2)+1:end)))/nnz(flowx(1:c(1), c(2)+1:end)), sum(sum(flowy(1:c(1), c(2)+1:end)))/nnz(flowy(1:c(1), c(2)+1:end))];
	BL = [sum(sum(flowx(c(1)+1:end, 1:c(2))))/nnz(flowx(c(1)+1:end, 1:c(2))), sum(sum(flowy(c(1)+1:end, 1:c(2))))/nnz(flowy(c(1)+1:end, 1:c(2)))];
	BR = [sum(sum(flowx(c(1)+1:end, c(2)+1:end)))/nnz(flowx(c(1)+1:end, c(2)+1:end)), ...
		  sum(sum(flowy(c(1)+1:end, c(2)+1:end)))/nnz(flowy(c(1)+1:end, c(2)+1:end))];
end
