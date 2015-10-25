function ptb_any_key(resp_device)
if nargin<1, resp_device = -1; end
while ~KbWait(resp_device, 2), end;
end