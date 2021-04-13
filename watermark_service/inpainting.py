from __future__ import print_function
import matplotlib.pyplot as plt

import os
# os.environ['CUDA_VISIBLE_DEVICES'] = '1'

import numpy as np
from models.resnet import ResNet
from models.unet import UNet
from models.skip import skip
import torch
import torch.optim

from utils.inpainting_utils import *

torch.backends.cudnn.enabled = True
torch.backends.cudnn.benchmark = True
dtype = torch.cuda.FloatTensor
# dtype = torch.FloatTensor

PLOT = True
imsize = -1
dim_div_by = 64

img_path = 'data/inpainting/bear_2.jpg'
mask_path = 'data/inpainting/bear.jpg'

img_pil, img_np = get_image(img_path, imsize)
img_mask_pil, img_mask_np = get_image(mask_path, imsize)

img_mask_pil = crop_image(img_mask_pil, dim_div_by)
img_pil      = crop_image(img_pil,      dim_div_by)

img_np      = pil_to_np(img_pil)
img_mask_np = pil_to_np(img_mask_pil)

img_mask_var = np_to_torch(img_mask_np).type(dtype)

plot_image_grid([img_np, img_mask_np, img_mask_np*img_np], 3,11)

def remove_watermark(img_np, img_mask_np):
    pad = 'reflection' # 'zero'
    OPT_OVER = 'net'
    OPTIMIZER = 'adam'

    INPUT = 'meshgrid'
    input_depth = 2
    LR = 0.01 
    num_iter = 5001
    param_noise = False

    net = skip(input_depth, img_np.shape[0], 
            num_channels_down = [128] * 5,
            num_channels_up   = [128] * 5,
            num_channels_skip = [0] * 5,  
            upsample_mode='nearest', filter_skip_size=1, filter_size_up=3, filter_size_down=3,
            need_sigmoid=True, need_bias=True, pad=pad, act_fun='LeakyReLU').type(dtype)

    net = net.type(dtype)
    net_input = get_noise(input_depth, INPUT, img_np.shape[1:]).type(dtype)

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
    noise = net_input.detach().clone()

    p = get_params(OPT_OVER, net, net_input)
    optimize(OPTIMIZER, p, closure, LR, num_iter)

    out_np = torch_to_np(net(net_input))

    return out_np