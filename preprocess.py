"""
This preprocessing script takes the fddb dataset and extracts rectangular face
regions into separate image files. Each face region is resized to 20x30.
"""

# http://vis-www.cs.umass.edu/fddb/
import uuid
import random

targets = [
    'dataset/fold-01.txt',
    'dataset/fold-02.txt',
    'dataset/fold-03.txt',
    'dataset/fold-04.txt',
    'dataset/fold-05.txt',
    'dataset/fold-06.txt',
    'dataset/fold-07.txt',
    'dataset/fold-08.txt',
    'dataset/fold-09.txt',
    'dataset/fold-10.txt'
]

def load_dataset ():
    faces = []
    for target in targets:
        lines = open(target, 'rb').readlines()
        lines = [line.strip() for line in lines]
        while len(lines) > 0:
            image_file = 'dataset/img/' + lines.pop(0) + '.jpg'
            for i in range(int(lines.pop(0))):
                values = map(float, lines.pop(0).split())
                faces += [(image_file, values)]
    return faces

import cv2
dataset = load_dataset()
for sample in dataset:
    print sample[0]
    image = cv2.imread(sample[0])
    cv2.imwrite(sample[0].replace('.jpg', '.png'), image)
