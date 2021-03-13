from matplotlib import image
import numpy as np
import cv2
import config
import matplotlib.pyplot as plt
import albumentations as A

def orig_augment(img):
    aug = A.OneOf([
        A.HorizontalFlip(),
        A.VerticalFlip(),
        A.Transpose(),
    ], p=0.8)
    image = aug(image=img)['image']
    return image

def augment(img):
    watermark = img.copy()
    if np.random.randint(0, 2):
        for x in range(0, img.shape[0], np.random.randint(2, 10)):
            for y in range(0, img.shape[1], np.random.randint(2, 20)):
                watermark[x,y] = 255
    cv2.putText(watermark, gen_word(), (np.random.randint(40, watermark.shape[0]//3), np.random.randint(watermark.shape[0]//4, watermark.shape[1] // 2)), cv2.FONT_HERSHEY_SIMPLEX, 20.0, (255, 255, 255), 40)
    alpha = np.random.uniform(low=0.3, high=0.6)
    img = cv2.addWeighted(img,alpha,watermark,1.-alpha,0)

    return img

def gen_word():
    abc = "qwertyuiopasdfghjklzxcvbnm123456879"
    return ''.join(abc[np.random.randint(0, high=len(abc))] for _ in range(np.random.randint(4, 10)))

def split_to_batch(img):
    splitted = []
    for x in range(config.size[0], img.shape[0], config.size[0]):
        for y in range(config.size[1], img.shape[1], config.size[1]):
            splitted.append(img[x-config.size[0]:x, y-config.size[1]:y])
            
    return splitted

    

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
