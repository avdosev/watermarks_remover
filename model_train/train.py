from matplotlib import image
import numpy as np
import cv2
import config
import matplotlib.pyplot as plt
import albumentations as A



    

if __name__ == "__main__":
    img = cv2.imread('data/train/image_1.jpg')
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = orig_augment(img)
    img = augment(img)
    plt.imshow(img)
    plt.show()
    # for sp_img in split_to_batch(img):
    #     plt.imshow(sp_img)
    #     plt.show()
