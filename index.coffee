ObjDetector = require("./src/ObjDetector")

fs = require('fs')
dataset = require("./data")
Canvas = require('canvas')
Image = require('canvas').Image

train_set = []
for i in [0...600]
    img = new Image()
    img.src = fs.readFileSync(dataset[i].image_file)
    canvas = new Canvas(img.width, img.height)
    ctx = canvas.getContext('2d')
    ctx.drawImage(img, 0, 0, img.width, img.height)
    train_set.push({
        image_file: dataset[i].image_file
        image_data: ctx.getImageData(0, 0, img.width, img.height)
        boxes: dataset[i].boxes
    })
console.log("loaded data")

detector = new ObjDetector()
detector.train(train_set)

i = 1000
img = new Image()
img.src = fs.readFileSync(dataset[i].image_file)
canvas = new Canvas(img.width, img.height)
ctx = canvas.getContext('2d')
ctx.drawImage(img, 0, 0, img.width, img.height)
thing = {
    image_file: dataset[i].image_file
    image_data: ctx.getImageData(0, 0, img.width, img.height)
    boxes: dataset[i].boxes
}

console.log(thing.image_file)
console.log(detector.detect(thing.image_data))

fs.writeFileSync("model.js", JSON.stringify(detector.save(), null, 4))

console.log("TEST TIME!!!")

fs = require('fs')
dataset = require("./data")
Canvas = require('canvas')
Image = require('canvas').Image

ObjDetector = require("./src/ObjDetector")
detector = new ObjDetector()
detector.load(JSON.parse(fs.readFileSync("model.js")))

match = (target_boxes, my_boxes) ->
    true_positive = 0
    false_positive = 0
    target_counter = (false for [0...target_boxes.length])
    for box in my_boxes
        found = false
        x = box.x + box.w / 2
        y = box.y + box.h / 2
        for i in [0...target_boxes.length]
            target = target_boxes[i]
            if target.x < x < target.x + target.w
                if target.y < y < target.y + target.h
                    target_counter[i] = true
                    true_positive++
                    found = true
                    break
        if not found
            false_positive++
    return {
        tp: true_positive
        fp: false_positive
        tc: target_counter
    }

train_set = []
for i in [1200...1210]
    img = new Image()
    img.src = fs.readFileSync(dataset[i].image_file)
    canvas = new Canvas(img.width, img.height)
    ctx = canvas.getContext('2d')
    ctx.drawImage(img, 0, 0, img.width, img.height)

    boxes = dataset[i].boxes
    results = detector.detect(ctx.getImageData(0, 0, img.width, img.height))
    console.log(match(boxes, results))
