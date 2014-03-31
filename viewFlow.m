function [] = viewFlow(title, flag)
	if flag == 1
		load([title '_flow.mat']);
		[h, w, channel, N] = size(uv);
		mean_flow = mean(mean(uv,1),2);
		net_flow = uv - repmat(mean_flow, [h w 1 1]);
		net_flow_mag = squeeze(sqrt(net_flow(:,:,1,:).^2+net_flow(:,:,2,:).^2));
	elseif flag == 2
		load([title '_flow2.mat']);
		[h, w, N] = size(vx);
		mean_flowx = mean(mean(vx));
		mean_flowy = mean(mean(vy));
		net_flow_mag = sqrt((vx-repmat(mean_flowx, [h w 1])).^2 + (vy-repmat(mean_flowy, [h w 1])).^2);
	end
	for i = 1 : N
		imagesc(net_flow_mag(:,:,i));
		pause(.1)
	end
end