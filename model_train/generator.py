from albumentations import augmentations
from albumentations.augmentations.functional import scale
import numpy as np
import cv2
import config
import matplotlib.pyplot as plt
import albumentations as A
import os

def augment(img):
    watermark = img.copy()
    if np.random.randint(0, 2):
        for x in range(0, img.shape[0], np.random.randint(2, 10)):
            for y in range(0, img.shape[1], np.random.randint(2, 20)):
                watermark[x,y] = 255
    cv2.putText(watermark, gen_word(), (np.random.randint(40, watermark.shape[0]//3), np.random.randint(watermark.shape[1]//4, watermark.shape[1] // 2)), cv2.FONT_HERSHEY_SIMPLEX, 20.0, (255, 255, 255), 40)
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

def main():
    path = 'data/originals'
    names = []
    for image_name in os.listdir('data/originals'):
        name = image_name.split('.')[0]
        print(name)
        img_orig = cv2.imread(os.path.join(path, image_name))

        if any([s < 320 for s in img_orig.shape[:-1]]):
            dsize = np.array(img_orig.shape[:-1])
            new_size = dsize / np.min(dsize / 320)
            img_orig = cv2.resize(img_orig, tuple(map(int, new_size)))
        
        augmentations = [
            A.HorizontalFlip(),
            A.VerticalFlip(),
            A.Transpose(),
        ]

        for j, augmentation in enumerate(augmentations):
            img = augmentation(image=img_orig)['image']

            for i, batched in enumerate(split_to_batch(img)):
                batch_name = f'{name}_{j}_{i}.jpg'
                names.append(batch_name)
                cv2.imwrite(f'data/test/{batch_name}', batched)
            
            img_aug = augment(img)
            for i, batched in enumerate(split_to_batch(img_aug)):
                batch_name = f'{name}_{j}_{i}.jpg'
                cv2.imwrite(f'data/train/{batch_name}', batched)
    
    with open('data/names.txt', 'w') as f:
        for name in names:
            print(name, file=f)


if __name__ == "__main__":
    main()