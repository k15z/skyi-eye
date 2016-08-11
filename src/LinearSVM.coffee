# # LinearSVM.coffee
# This is a ridiculously lightweight linear support vector machine implementation. It uses gradient
# descent to find a hyperplane (binary classification only) between the +1 and -1 samples. It may 
# or may not converge on the optimal hyperplane - depending on performance, may be reimplemented as
# a kernel support vector machine.

class LinearSVM

    # - `opts.lr_rate` is the learning rate (default: 0.01)
    # - `opts.epochs` is the number of training cycles (default: 1000)
    # - `opts.verbose` is whether to print each cycle (default: true)
    constructor: (opts={}) ->
        @l_rate = if opts.l_rate? then opts.l_rate else 0.01
        @epochs = if opts.epochs? then opts.epochs else 1000
        @verbose = if opts.verbose? then opts.verbose else true

    # Load the bias and weight terms. Options not included.
    load: (obj) ->
        @bias = obj.bias
        @weight = obj.weight

    # Export the bias and weight terms. Options not included.
    save: ->
        return {
            bias: @bias
            weight: @weight
        }

    # - `x` is a 2d array of size `num_samples` by `num_features`
    # - `y` is an array of size `num_features` that only contains +/= 1 
    fit: (x, y) ->
        num_samples = x.length
        num_features = x[0].length
        if not @bias or not @weight
            @bias = 0.5 - Math.random()
            @weight = (0.5 - Math.random() for [0...num_features])
        for e in [0...@epochs]
            incorrect = 0
            for i in [0...num_samples]
                if @predict_one(x[i]) * y[i] < 1
                    incorrect++
                    for j in [0...@weight.length]
                        @weight[j] += @l_rate * x[i][j] * y[i]
                        @bias += @l_rate * y[i]
            accuracy = 1.0 - incorrect / num_samples
            if @verbose and e % 100 == 0
                console.log(@weight)
                console.log("epoch #{e}: #{accuracy} acc")

    # - `x` is a 2d array of size `num_samples` by `num_features`
    predict: (x) ->
        y = []
        for x_i in x
            y.push(@predict_one(x_i))
        return y

    # - `x` is an array of size `num_features`
    predict_one: (x_i) ->
        y_i = @bias
        for j in [0...@weight.length]
            y_i += @weight[j] * x_i[j]
        return y_i

module.exports = LinearSVM
