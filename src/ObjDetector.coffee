Canvas = require('canvas')
HoGImage = require("./HoGImage")
LinearSVM = require("./LinearSVM")
SVM = require('svm').SVM

# HoG-SVM powered object detector
class ObjDetector
    constructor: () ->
        @w = 40
        @h = 50
        @c = 8
        @r = 10
        @svm = new SVM()

    load: (obj) ->
        @w = obj.w
        @h = obj.h
        @svm = new SVM()
        @svm.fromJSON(obj.svm)

    save: ->
        return {
            w: @w
            h: @h
            svm: @svm.toJSON()
        }

    detect: (image_data, scales=[0.2, 0.4, 0.6, 0.8]) ->
        boxes = []
        base = new Canvas(image_data.width, image_data.height)
        base.getContext('2d').putImageData(image_data, 0, 0)
        for scale in scales
            width = Math.floor(image_data.width*scale)
            height = Math.floor(image_data.height*scale)
            canvas = new Canvas(width, height)
            canvas.getContext('2d').drawImage(base, 0, 0, width, height)
            boxes = boxes.concat(@_detect(canvas.getContext('2d').getImageData(0, 0, width, height), scale))
        boxes.sort((a, b) -> b.score - a.score)
        return boxes

    _detect: (image_data, scale) ->
        boxes = []
        image_data.hog = new HoGImage(image_data)
        {data, width, height} = image_data
        for y in [0...height-@h] by 5
            for x in [0...width-@w] by 5
                vector = image_data.hog.histogram({
                    x: x, y: y, w: @w, h: @h
                }, @r, @c)
                if @svm.predictOne(vector) > 0
                    boxes.push({
                        x: x/scale, y: y/scale, w: @w/scale, h: @h/scale
                        score: @svm.predictOne(vector), scale: scale
                    })
        boxes.sort((a, b) -> b.score - a.score)
        return boxes

    train: (examples) ->
        x = []
        y = []
        for example in examples
            example.hog = new HoGImage(example.image_data)
            for box in example.boxes
                if box.x + box.w > example.image_data.width - 1
                    continue
                if box.y + box.h > example.image_data.height - 1
                    continue
                x.push(example.hog.histogram(box, @r, @c))
                y.push(1)
                x.push(example.hog.histogram(@_get_negative_sample(example), @r, @c))
                y.push(-1)
        @svm.train(x, y)

        wrong = 0
        for example in examples
            for j in [0...10]
                sample = example.hog.histogram(@_get_negative_sample(example), @r, @c)
                if @svm.predict_one(sample) > 1 # wrong!
                    wrong++
                    x.push(sample)
                    y.push(-1)
        console.log("found #{wrong} mistakes in #{examples.length}00")
        @svm.train(x, y)

    _get_negative_sample: (example) ->
        return {
            x: Math.floor(Math.random() * (example.image_data.width - 20)),
            y: Math.floor(Math.random() * (example.image_data.height - 30)),
            w: 20,
            h: 30,
        }
    
module.exports = ObjDetector
