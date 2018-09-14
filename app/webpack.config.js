const path = require("path");
const webpack = require("webpack");
const CopyWebpackPlugin = require("copy-webpack-plugin")
const MiniCSSExtractPlugin = require('mini-css-extract-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin');
const { CheckerPlugin } = require('awesome-typescript-loader');
const CleanWebpackPlugin = require('clean-webpack-plugin');

module.exports = {
    target: "web",
    entry: [
        "./src/index.tsx",
        "./scss/styles.scss"
    ],
    output: {
        filename: "[name].[hash].js",
        path: path.join(__dirname, './dist'),
    },

    // Enable sourcemaps for debugging webpack's output.
    devtool: "source-map",

    resolve: {
        // Add '.ts' and '.tsx' as resolvable extensions.
        extensions: [".ts", ".tsx", ".js", ".json"]
    },

    devServer: {
        contentBase: './dist',
        hot: true,
        historyApiFallback: true,
    },

    module: {
        rules: [
            // All files with a '.ts' or '.tsx' extension will be handled by 'awesome-typescript-loader'.
            { test: /\.tsx?$/, loader: "awesome-typescript-loader" },

            // All output '.js' files will have any sourcemaps re-processed by 'source-map-loader'.
            { enforce: "pre", test: /\.js$/, loader: "source-map-loader", exclude: [/node_modules\/reflect-metadata/] },

            {
                test: /\.scss$/,
                use: [
                    MiniCSSExtractPlugin.loader,
                    { loader: 'css-loader', options: { importLoaders: 1 } },
                    'postcss-loader',
                    'sass-loader'
                ]
            },

            { test: /\.css$/, use: ['style-loader', 'css-loader'] },
            { test: /\.(png|woff|woff2|eot|ttf|svg)$/, use: [{ loader: 'url-loader', options: { limit: 10000 } }] }
        ]
    },

    plugins: [
        new CleanWebpackPlugin(['dist'], { root: path.join(__dirname, '.') }),
        new CheckerPlugin({
            useCache: true
        }),
        new MiniCSSExtractPlugin({
            filename: 'styles.css'
        }),
        new HtmlWebpackPlugin({
            title: "WebCAT",
            template: "index.html"
        }),
        new HardSourceWebpackPlugin(),
        new CopyWebpackPlugin([{ from: path.join(__dirname, 'static') }]),
        new webpack.HotModuleReplacementPlugin()
    ],
    resolve: {
        // Add '.ts' and '.tsx' as resolvable extensions.
        extensions: ['.ts', '.tsx', '.js', '.jsx', '.json'],
    },
    externals: {
        // Use external version of React
        "react": "React",
        "react-dom": "ReactDOM"
    },
};