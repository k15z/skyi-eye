fs = require('fs')
path = require('path')

dataset = []
for id in ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10']
    file = path.join(__dirname, "fold-#{id}.txt")
    lines = fs.readFileSync(file, "utf8").split(/\r|\n/)
    while lines.length > 1
        image_file = "data/img/" + lines.shift() + ".png"
        num_boxes = parseInt(lines.shift())
        boxes = []
        for i in [0...num_boxes]
            values = lines.shift().split(' ')
            major_axis_radius = parseFloat(values[0])
            minor_axis_radius = parseFloat(values[1])
            center_x = parseFloat(values[3])
            center_y = parseFloat(values[4])
            thing = {
                x: Math.floor(center_x - minor_axis_radius)
                y: Math.floor(center_y - major_axis_radius)
                w: Math.floor(minor_axis_radius * 2)
                h: Math.floor(major_axis_radius * 2)
            }
            if thing.x < 0 || thing.y < 0
                continue
            boxes.push(thing)
        dataset.push({
            image_file: image_file
            boxes: boxes
        })

module.exports = dataset
