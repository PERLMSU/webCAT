const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin')
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
    entry: ['./js/app.js', './scss/styles.scss'],
    output: {
        filename: 'js/main.js',
        path: path.resolve(__dirname, '../priv/static'),
        publicPath: "/static"
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                },
            },
            {
                test: /\.scss$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    "css-loader",
                    "sass-loader"
                ]
            }
        ],
    },
    resolve: {
        modules: ['node_modules', path.resolve(__dirname, 'js')],
        extensions: ['.js'],
    },
    plugins: [
        new CopyWebpackPlugin([{ from: "./static", to: path.resolve(__dirname, "../priv/static/") }]),
        new MiniCssExtractPlugin({
            // Options similar to the same options in webpackOptions.output
            // both options are optional
            filename: "css/[name].css",
            chunkFilename: "css/[id].css"
        })
    ]
};