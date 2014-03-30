function [] = viewFlow(title)
	load([title '_flow.mat']);
	[h, w, channel, N] = size(uv);
	mean_flow = mean(mean(uv,1),2);
	net_flow = uv - repmat(mean_flow, [h w 1 1]);
	net_flow_mag = squeeze(sqrt(net_flow(:,:,1,:).^2+net_flow(:,:,2,:).^2));
	for i = 1 : N
		imagesc(net_flow_mag(:,:,i));
		pause(.1)
	end
end