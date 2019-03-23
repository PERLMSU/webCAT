const path = require('path');
const glob = require('glob');
const CopyWebpackPlugin = require('copy-webpack-plugin')
const MiniCSSExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');

module.exports = (env, options) => ({
    optimization: {
        minimizer: [
            new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
            new OptimizeCSSAssetsPlugin({})
        ]
    },
    entry: {
        app: './js/app.js',
        draft: './js/draft.js',
        form: './js/form.js',
        messages: './js/messages.js',
        file: './js/file.js',
        feedback: './js/feedback.js',
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../priv/static/js')
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader'
                }
            },
            {
                test: /\.scss$/,
                use: [
                    MiniCSSExtractPlugin.loader,
                    {loader: 'css-loader', options: {importLoaders: 1}},
                    'postcss-loader',
                    'sass-loader'
                ]
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                  loader: 'elm-webpack-loader',
                  options: {
                    debug: options.mode === "development"
                  }
                }
            },
            {test: /\.css$/, use: [MiniCSSExtractPlugin.loader, 'css-loader']},
        ]
    },
    plugins: [
        new MiniCSSExtractPlugin({ filename: '../css/[name].css' }),
        new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/@fortawesome/fontawesome-pro/webfonts/', to: '../webfonts' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/@fortawesome/fontawesome-pro/css/all.min.css', to: '../css/fa.min.css' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/selectize/dist/css/selectize.default.css', to: '../css/selectize.min.css' }]),
    ]
});