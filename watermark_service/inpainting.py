import numpy as np
from models.skip import skip
import torch
import torch.optim

from utils.common_utils import *

torch.backends.cudnn.enabled = True
torch.backends.cudnn.benchmark = True
dtype = torch.cuda.FloatTensor
# dtype = torch.FloatTensor

def remove_watermark(img_np, img_mask_np):
    pad = 'reflection' # 'zero'
    OPT_OVER = 'net'
    OPTIMIZER = 'adam'

    input_depth = 3
    LR = 0.01 
    num_iter = 2500
    param_noise = False
    print(img_np.shape[0])
    net = skip(input_depth, img_np.shape[0], 
           num_channels_down = [16,32,64,128,128],
           num_channels_up   = [16,32,64,128,128],
           num_channels_skip = [0]*5,  
           upsample_mode='nearest', filter_skip_size=1, filter_size_up=3, filter_size_down=3,
           need_sigmoid=True, need_bias=True, pad=pad, act_fun='LeakyReLU').type(dtype)

    net = net.type(dtype)
    net_input = np_to_torch(img_np).type(dtype)

    # Compute number of parameters
    s  = sum(np.prod(list(p.size())) for p in net.parameters())
    print ('Number of params: %d' % s)

    # Loss
    mse = torch.nn.MSELoss().type(dtype)

    img_var = np_to_torch(img_np).type(dtype)
    mask_var = np_to_torch(img_mask_np).type(dtype)

    i = 0
    def closure():
        
        nonlocal i
        
        if param_noise:
            for n in [x for x in net.parameters() if len(x.size()) == 4]:
                n = n + n.detach().clone().normal_() * n.std() / 50
        
        net_input = net_input_saved            
            
        out = net(net_input)
    
        total_loss = mse(out * mask_var, img_var * mask_var)
        total_loss.backward()
            
        print ('Iteration %05d    Loss %f' % (i, total_loss.item()), '\r', end='')
            
        i += 1

        return total_loss

    net_input_saved = net_input.detach().clone()

    p = get_params(OPT_OVER, net, net_input)
    optimize(OPTIMIZER, p, closure, LR, num_iter)

    out_np = torch_to_np(net(net_input))

    return out_np