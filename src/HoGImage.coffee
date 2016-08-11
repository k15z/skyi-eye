# # HoGImage.coffee
# This wraps around ImageData-like objects and implements a histogram of oriented gradients, making
# it easy for other classes to efficiently retrieve the gradient histogram for sub-windows. This is
# very likely to have bugs - javascript will happily hit a NaN and keep going.

class HoGImage
    num_bins = 16

    constructor: (image_data) ->
        data = image_data.data
        @width = image_data.width
        @height = image_data.height

        luma = []
        for y in [0...@height]
            row = []
            for x in [0...@width]
                r = data[(y*@width+x)*4+0]
                g = data[(y*@width+x)*4+1]
                b = data[(y*@width+x)*4+2]
                row.push(r + g + b)
            luma.push(row)

        @grad = []
        for y in [0...@height]
            row = []
            for x in [0...@width]
                if y == 0 or y == @height - 1 
                    row.push(0)
                else if x == 0 or x == @width - 1 
                    row.push(0)
                else
                    dy = luma[y-1][x] - luma[y+1][x]
                    dx = luma[y][x+1] - luma[y][x-1]
                    angle = Math.atan2(dy, dx)
                    assert?.ok(!isNaN(angle))
                    row.push(angle)
            @grad.push(row)

    histogram: (box, rows=1, cols=1) ->
        vector = []
        cell_w = box.w / cols
        cell_h = box.h / rows
        for c in [0...cols]
            for r in [0...rows]
                vector = vector.concat(@_histogram({
                    x: Math.floor(box.x + c * cell_w)
                    y: Math.floor(box.y + r * cell_h)
                    w: Math.floor(cell_w)
                    h: Math.floor(cell_h)
                }))
        return vector

    _histogram: (box) ->
        bins = (0 for [0...num_bins])
        for y in [box.y...box.y+box.h]
            for x in [box.x...box.x+box.w]
                angle = (@grad[y][x] + Math.PI - 1e-10) / (2 * Math.PI)
                bins[Math.floor(angle * num_bins)]++;
        total = bins.reduce((t, s) -> t + s)
        bins = (i / total for i in bins)
        return bins

module.exports = HoGImage
