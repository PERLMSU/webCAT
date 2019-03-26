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
        form: './js/form.js',
        messages: './js/messages.js',
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
            }
        ]
    },
    plugins: [
        new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
        new CopyWebpackPlugin([{ from: 'semantic/dist/semantic.min.css', to: '../css/semantic.min.css' }]),
        new CopyWebpackPlugin([{ from: 'semantic/dist/semantic.min.js', to: '../js/semantic.min.js' }]),
        new CopyWebpackPlugin([{ from: 'semantic/dist/themes/default/assets/fonts', to: '../webfonts' }]),
        new CopyWebpackPlugin([{ from: 'semantic/dist/themes/default/assets/images', to: '../images' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/selectize/dist/css/selectize.default.css', to: '../css/selectize.min.css' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/@fortawesome/fontawesome-pro/webfonts/', to: '../webfonts' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/@fortawesome/fontawesome-pro/css/all.min.css', to: '../css/fa.min.css' }]),
    ]
});        
